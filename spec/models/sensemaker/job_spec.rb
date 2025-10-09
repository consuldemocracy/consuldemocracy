require "rails_helper"

describe Sensemaker::Job do
  let(:user) { create(:user) }
  let(:debate) { create(:debate) }
  let(:job) do
    create(:sensemaker_job,
           commentable_type: "Debate",
           commentable_id: debate.id,
           script: "categorization_runner.ts",
           user: user,
           started_at: Time.current,
           additional_context: "Test context")
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(job).to be_valid
    end

    it "requires commentable_type" do
      job.commentable_type = nil
      expect(job).not_to be_valid
    end

    it "requires commentable_id" do
      job.commentable_id = nil
      expect(job).not_to be_valid
    end
  end

  describe "associations" do
    it "belongs to a user" do
      expect(job.user).to eq(user)
    end
  end

  describe "instance methods" do
    describe "#started?" do
      it "returns true when started_at is present" do
        expect(job.started?).to be true
      end

      it "returns false when started_at is nil" do
        job.started_at = nil
        expect(job.started?).to be false
      end
    end

    describe "#finished?" do
      it "returns true when finished_at is present" do
        job.finished_at = Time.current
        expect(job.finished?).to be true
      end

      it "returns false when finished_at is nil" do
        expect(job.finished?).to be false
      end
    end

    describe "#errored?" do
      it "returns true when error is present" do
        job.error = "Some error occurred"
        expect(job.errored?).to be true
      end

      it "returns false when error is nil" do
        expect(job.errored?).to be false
      end
    end

    describe "#has_output?" do
      it "returns true when persisted_output is present and file exists" do
        job.persisted_output = "/path/to/existing/file.txt"
        allow(File).to receive(:exist?).and_return(false) # default
        allow(File).to receive(:exist?).with("/path/to/existing/file.txt").and_return(true)
        expect(job.has_output?).to be true
      end

      it "returns false when persisted_output is nil" do
        job.persisted_output = nil
        expect(job.has_output?).to be false
      end

      it "returns false when persisted_output is present but file does not exist" do
        job.persisted_output = "/path/to/nonexistent/file.txt"
        allow(File).to receive(:exist?).and_return(false) # default
        allow(File).to receive(:exist?).with("/path/to/nonexistent/file.txt").and_return(false)
        expect(job.has_output?).to be false
      end
    end

    describe "#cleanup_associated_files" do
      let(:data_folder) { "/tmp/sensemaker_test_folder/data" }

      before do
        allow(Sensemaker::JobRunner).to receive(:sensemaker_data_folder).and_return(data_folder)
        allow(FileUtils).to receive(:rm_f).and_return(true)
        allow(Rails.logger).to receive(:info)
        allow(Rails.logger).to receive(:warn)
      end

      it "cleans up input files" do
        expect(FileUtils).to receive(:rm_f).with("#{data_folder}/input-#{job.id}.csv")
        expect(FileUtils).to receive(:rm_f).with("#{data_folder}/input-#{job.id}.csv.unfiltered")

        job.send(:cleanup_input_files, data_folder)
      end

      context "when script is health_check_runner.ts" do
        let(:job) { create(:sensemaker_job, script: "health_check_runner.ts") }

        it "cleans up health check output file" do
          expect(FileUtils).to receive(:rm_f).with("#{data_folder}/health-check-#{job.id}.txt")

          job.send(:cleanup_output_files, data_folder)
        end
      end

      context "when script is advanced_runner.ts" do
        let(:job) { create(:sensemaker_job, script: "advanced_runner.ts") }

        it "cleans up all advanced runner output files" do
          expect(FileUtils).to receive(:rm_f).with("#{data_folder}/output-#{job.id}-summary.json")
          expect(FileUtils).to receive(:rm_f).with("#{data_folder}/output-#{job.id}-topic-stats.json")
          expect(FileUtils).to receive(:rm_f).with(
            "#{data_folder}/output-#{job.id}-comments-with-scores.json"
          )

          job.send(:cleanup_output_files, data_folder)
        end
      end

      context "when script is categorization_runner.ts" do
        let(:job) { create(:sensemaker_job, script: "categorization_runner.ts") }

        it "cleans up categorization output file" do
          expect(FileUtils).to receive(:rm_f).with("#{data_folder}/categorization-output-#{job.id}.csv")

          job.send(:cleanup_output_files, data_folder)
        end
      end

      context "when script is single-html-build.js" do
        let(:job) { create(:sensemaker_job, script: "single-html-build.js") }

        it "cleans up HTML report file" do
          expect(FileUtils).to receive(:rm_f).with("#{data_folder}/report-#{job.id}.html")

          job.send(:cleanup_output_files, data_folder)
        end
      end

      context "when script is default" do
        let(:job) { create(:sensemaker_job, script: "runner.ts") }

        it "cleans up default output file" do
          expect(FileUtils).to receive(:rm_f).with("#{data_folder}/output-#{job.id}.csv")

          job.send(:cleanup_output_files, data_folder)
        end
      end

      describe "#cleanup_persisted_output" do
        context "when persisted_output is present and file exists" do
          before do
            job.persisted_output = "/path/to/output.txt"
            allow(File).to receive(:exist?).and_return(false)
            allow(File).to receive(:exist?).with("/path/to/output.txt").and_return(true)
          end

          it "removes the persisted output file" do
            expect(FileUtils).to receive(:rm_f).with("/path/to/output.txt")

            job.send(:cleanup_persisted_output)
          end
        end

        context "when persisted_output is nil" do
          before do
            job.persisted_output = nil
          end

          it "does not attempt to remove any file" do
            expect(FileUtils).not_to receive(:rm_f)

            job.send(:cleanup_persisted_output)
          end
        end

        context "when persisted_output is present but file does not exist" do
          before do
            job.persisted_output = "/path/to/nonexistent.txt"
            allow(File).to receive(:exist?).and_return(false)
            allow(File).to receive(:exist?).with("/path/to/nonexistent.txt").and_return(false)
          end

          it "does not attempt to remove the file" do
            expect(FileUtils).not_to receive(:rm_f)

            job.send(:cleanup_persisted_output)
          end
        end
      end

      it "logs cleanup results" do
        allow(FileUtils).to receive(:rm_f).and_return(true)

        expect(Rails.logger).to receive(:info).with(/Cleaned up files for job #{job.id}/)

        job.send(:cleanup_associated_files)
      end

      it "handles errors gracefully" do
        allow(FileUtils).to receive(:rm_f).and_raise(StandardError.new("File system error"))

        expect(Rails.logger).to receive(:warn).with(/Failed to cleanup files for job #{job.id}/)

        result = job.send(:cleanup_associated_files)
        expect(result).to be(nil)
      end
    end
  end

  describe "callbacks" do
    describe "after_destroy" do
      let(:data_folder) { "/tmp/sensemaker_test_folder/data" }

      before do
        allow(Sensemaker::JobRunner).to receive(:sensemaker_data_folder).and_return(data_folder)
        allow(FileUtils).to receive(:rm_f).and_return(true)
        allow(Rails.logger).to receive(:info)
        allow(Rails.logger).to receive(:warn)
      end

      it "calls cleanup_associated_files when job is destroyed" do
        expect(job).to receive(:cleanup_associated_files)
        job.destroy!
      end

      it "continues with destruction even if cleanup fails" do
        expect(job).to receive(:cleanup_input_files)

        expect(job).to receive(:cleanup_output_files)
        allow(job).to receive(:cleanup_output_files).and_raise(StandardError.new("Bork"))

        expect { job.destroy }.not_to raise_error
        expect(Sensemaker::Job.find_by(id: job.id)).to be(nil)
      end
    end
  end
end
