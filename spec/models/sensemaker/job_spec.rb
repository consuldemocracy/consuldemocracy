require "rails_helper"

describe Sensemaker::Job do
  let(:user) { create(:user) }
  let(:debate) { create(:debate) }
  let(:job) do
    create(:sensemaker_job,
           analysable_type: "Debate",
           analysable_id: debate.id,
           script: "categorization_runner.ts",
           user: user,
           started_at: Time.current,
           additional_context: "Test context")
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(job).to be_valid
    end

    it "requires analysable_type" do
      job.analysable_type = nil
      expect(job).not_to be_valid
    end

    it "requires analysable_id for non-Proposal types" do
      job.analysable_id = nil
      expect(job).not_to be_valid
    end

    it "allows nil analysable_id for Proposal type" do
      job.analysable_type = "Proposal"
      job.analysable_id = nil
      expect(job).to be_valid
    end

    describe "#publishing_is_allowed" do
      let(:data_folder) { "/tmp/sensemaker_test_folder/data" }

      before do
        allow(Sensemaker::Paths).to receive(:sensemaker_data_folder).and_return(data_folder)
        allow(File).to receive(:exist?).and_return(false)
        job.published = false
      end

      context "when job is publishable" do
        before do
          job.script = "single-html-build.js"
          job.finished_at = Time.current
          job.error = nil
          output_path = "#{data_folder}/report-#{job.id}.html"
          allow(File).to receive(:exist?).with(output_path).and_return(true)
        end

        it "allows publishing when changing from false to true" do
          job.published = true
          expect(job).to be_valid
        end
      end

      context "when job is not publishable" do
        it "adds validation error when published is changed to true" do
          # Set up a job that is not publishable (any condition fails)
          job.script = "categorization_runner.ts"
          job.finished_at = Time.current
          job.error = nil
          job.published = true

          expect(job).not_to be_valid
          expect(job.errors[:published]).to be_present
        end
      end

      context "when job is already published" do
        before do
          job.published = true
          job.save!(validate: false) # Save without validation to set initial state
        end

        it "does not validate when already published" do
          job.script = "categorization_runner.ts" # Make it unpublishable
          job.finished_at = nil
          expect(job).to be_valid
        end
      end

      context "when job is not published" do
        it "does not validate publishable status" do
          job.script = "categorization_runner.ts"
          job.finished_at = nil
          job.published = false
          expect(job).to be_valid
        end
      end
    end
  end

  describe "associations" do
    it "belongs to a user" do
      expect(job.user).to eq(user)
    end
  end

  describe "instance methods" do
    describe "#has_multiple_outputs?" do
      it "returns true for advanced_runner.ts and runner.ts" do
        job.script = "advanced_runner.ts"
        expect(job.has_multiple_outputs?).to be true
        job.script = "runner.ts"
        expect(job.has_multiple_outputs?).to be true
      end

      it "returns false for single output scripts" do
        job.script = "categorization_runner.ts"
        expect(job.has_multiple_outputs?).to be false
        job.script = "health_check_runner.ts"
        expect(job.has_multiple_outputs?).to be false
        job.script = "single-html-build.js"
        expect(job.has_multiple_outputs?).to be false
      end
    end

    describe "#output_file_name" do
      it "returns the correct output file name for each script" do
        job.script = "categorization_runner.ts"
        expect(job.output_file_name).to eq("categorization-output-#{job.id}.csv")

        job.script = "advanced_runner.ts"
        expect(job.output_file_name).to eq("output-#{job.id}")

        job.script = "runner.ts"
        expect(job.output_file_name).to eq("output-#{job.id}")

        job.script = "health_check_runner.ts"
        expect(job.output_file_name).to eq("health-check-#{job.id}.txt")

        job.script = "single-html-build.js"
        expect(job.output_file_name).to eq("report-#{job.id}.html")
      end
    end

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

    describe "#cancelled?" do
      it "returns true when finished_at is present and error is 'Cancelled'" do
        job.finished_at = Time.current
        job.error = "Cancelled"
        expect(job.cancelled?).to be true
      end
    end

    describe "cancel!" do
      it "updates the job with finished_at and error 'Cancelled'" do
        job.cancel!
        expect(job.finished_at).to be_present
        expect(job.error).to eq("Cancelled")
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

    describe "#default_output_path" do
      let(:data_folder) { "/tmp/sensemaker_test_folder/data" }

      before do
        allow(Sensemaker::Paths).to receive(:sensemaker_data_folder).and_return(data_folder)
      end

      it "returns the correct path for categorization_runner.ts" do
        job.script = "categorization_runner.ts"
        expect(job.default_output_path).to eq("#{data_folder}/categorization-output-#{job.id}.csv")
      end

      it "returns the correct path for advanced_runner.ts" do
        job.script = "advanced_runner.ts"
        expect(job.default_output_path).to eq("#{data_folder}/output-#{job.id}")
      end

      it "returns the correct path for runner.ts" do
        job.script = "runner.ts"
        expect(job.default_output_path).to eq("#{data_folder}/output-#{job.id}")
      end
    end

    describe "#output_artifact_paths" do
      let(:data_folder) { "/tmp/sensemaker_test_folder/data" }
      let(:base_path) { "#{data_folder}/output-#{job.id}" }

      before do
        allow(Sensemaker::Paths).to receive(:sensemaker_data_folder).and_return(data_folder)
      end

      context "when persisted_output is not set" do
        it "uses default_output_path for single output scripts" do
          job.script = "categorization_runner.ts"
          expected_path = "#{data_folder}/categorization-output-#{job.id}.csv"
          expect(job.output_artifact_paths).to eq([expected_path])
        end

        it "uses default_output_path for advanced_runner.ts" do
          job.script = "advanced_runner.ts"
          expect(job.output_artifact_paths).to eq([
            "#{base_path}-summary.json",
            "#{base_path}-topic-stats.json",
            "#{base_path}-comments-with-scores.json"
          ])
        end

        it "uses default_output_path for runner.ts" do
          job.script = "runner.ts"
          expect(job.output_artifact_paths).to eq([
            "#{base_path}-summary.json",
            "#{base_path}-summary.html",
            "#{base_path}-summary.md",
            "#{base_path}-summaryAndSource.csv"
          ])
        end
      end

      context "when persisted_output is set" do
        let(:persisted_path) { "/historical/path/output-#{job.id}" }

        before do
          job.persisted_output = persisted_path
        end

        it "uses persisted_output for single output scripts" do
          job.script = "categorization_runner.ts"
          expect(job.output_artifact_paths).to eq([persisted_path])
        end

        it "uses persisted_output for advanced_runner.ts" do
          job.script = "advanced_runner.ts"
          expect(job.output_artifact_paths).to eq([
            "#{persisted_path}-summary.json",
            "#{persisted_path}-topic-stats.json",
            "#{persisted_path}-comments-with-scores.json"
          ])
        end

        it "uses persisted_output for runner.ts" do
          job.script = "runner.ts"
          expect(job.output_artifact_paths).to eq([
            "#{persisted_path}-summary.json",
            "#{persisted_path}-summary.html",
            "#{persisted_path}-summary.md",
            "#{persisted_path}-summaryAndSource.csv"
          ])
        end
      end
    end

    describe "#has_outputs?" do
      let(:data_folder) { "/tmp/sensemaker_test_folder/data" }

      before do
        allow(Sensemaker::Paths).to receive(:sensemaker_data_folder).and_return(data_folder)
        allow(File).to receive(:exist?).and_return(false)
      end

      context "when script has single output" do
        before do
          job.script = "categorization_runner.ts"
        end

        it "returns true when the output file exists" do
          output_path = "#{data_folder}/categorization-output-#{job.id}.csv"
          allow(File).to receive(:exist?).with(output_path).and_return(true)
          expect(job.has_outputs?).to be true
        end

        it "returns false when the output file does not exist" do
          expect(job.has_outputs?).to be false
        end
      end

      context "when script has multiple outputs (advanced_runner.ts)" do
        before do
          job.script = "advanced_runner.ts"
        end

        it "returns true when all output files exist" do
          base_path = "#{data_folder}/output-#{job.id}"
          allow(File).to receive(:exist?).with("#{base_path}-summary.json").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-topic-stats.json").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-comments-with-scores.json").and_return(true)
          expect(job.has_outputs?).to be true
        end

        it "returns false when not all output files exist" do
          base_path = "#{data_folder}/output-#{job.id}"
          allow(File).to receive(:exist?).with("#{base_path}-summary.json").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-topic-stats.json").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-comments-with-scores.json").and_return(false)
          expect(job.has_outputs?).to be false
        end
      end

      context "when script has multiple outputs (runner.ts)" do
        before do
          job.script = "runner.ts"
        end

        it "returns true when all output files exist" do
          base_path = "#{data_folder}/output-#{job.id}"
          allow(File).to receive(:exist?).with("#{base_path}-summary.json").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-summary.html").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-summary.md").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-summaryAndSource.csv").and_return(true)
          expect(job.has_outputs?).to be true
        end

        it "returns false when not all output files exist" do
          base_path = "#{data_folder}/output-#{job.id}"
          allow(File).to receive(:exist?).with("#{base_path}-summary.json").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-summary.html").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-summary.md").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-summaryAndSource.csv").and_return(false)
          expect(job.has_outputs?).to be false
        end
      end
    end

    describe "#publishable?" do
      let(:data_folder) { "/tmp/sensemaker_test_folder/data" }

      before do
        allow(Sensemaker::Paths).to receive(:sensemaker_data_folder).and_return(data_folder)
        allow(File).to receive(:exist?).and_return(false)
      end

      context "when script is single-html-build.js" do
        before do
          job.script = "single-html-build.js"
          job.finished_at = Time.current
          job.error = nil
        end

        it "returns true when all conditions are met" do
          output_path = "#{data_folder}/report-#{job.id}.html"
          allow(File).to receive(:exist?).with(output_path).and_return(true)
          expect(job.publishable?).to be true
        end

        it "returns false when job is not finished" do
          job.finished_at = nil
          output_path = "#{data_folder}/report-#{job.id}.html"
          allow(File).to receive(:exist?).with(output_path).and_return(true)
          expect(job.publishable?).to be false
        end

        it "returns false when job has errors" do
          job.error = "Some error occurred"
          output_path = "#{data_folder}/report-#{job.id}.html"
          allow(File).to receive(:exist?).with(output_path).and_return(true)
          expect(job.publishable?).to be false
        end

        it "returns false when job has no outputs" do
          expect(job.publishable?).to be false
        end
      end

      context "when script is runner.ts" do
        before do
          job.script = "runner.ts"
          job.finished_at = Time.current
          job.error = nil
        end

        it "returns true when all conditions are met" do
          base_path = "#{data_folder}/output-#{job.id}"
          allow(File).to receive(:exist?).with("#{base_path}-summary.json").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-summary.html").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-summary.md").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-summaryAndSource.csv").and_return(true)
          expect(job.publishable?).to be true
        end

        it "returns false when job is not finished" do
          job.finished_at = nil
          base_path = "#{data_folder}/output-#{job.id}"
          allow(File).to receive(:exist?).with("#{base_path}-summary.json").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-summary.html").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-summary.md").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-summaryAndSource.csv").and_return(true)
          expect(job.publishable?).to be false
        end

        it "returns false when job has errors" do
          job.error = "Some error occurred"
          base_path = "#{data_folder}/output-#{job.id}"
          allow(File).to receive(:exist?).with("#{base_path}-summary.json").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-summary.html").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-summary.md").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-summaryAndSource.csv").and_return(true)
          expect(job.publishable?).to be false
        end

        it "returns false when job has no outputs" do
          expect(job.publishable?).to be false
        end
      end

      context "when script is not publishable" do
        before do
          job.finished_at = Time.current
          job.error = nil
        end

        it "returns false for categorization_runner.ts even when other conditions are met" do
          job.script = "categorization_runner.ts"
          output_path = "#{data_folder}/categorization-output-#{job.id}.csv"
          allow(File).to receive(:exist?).with(output_path).and_return(true)
          expect(job.publishable?).to be false
        end

        it "returns false for advanced_runner.ts even when other conditions are met" do
          job.script = "advanced_runner.ts"
          base_path = "#{data_folder}/output-#{job.id}"
          allow(File).to receive(:exist?).with("#{base_path}-summary.json").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-topic-stats.json").and_return(true)
          allow(File).to receive(:exist?).with("#{base_path}-comments-with-scores.json").and_return(true)
          expect(job.publishable?).to be false
        end

        it "returns false for health_check_runner.ts even when other conditions are met" do
          job.script = "health_check_runner.ts"
          output_path = "#{data_folder}/health-check-#{job.id}.txt"
          allow(File).to receive(:exist?).with(output_path).and_return(true)
          expect(job.publishable?).to be false
        end
      end
    end

    describe "#cleanup_associated_files" do
      let(:data_folder) { "/tmp/sensemaker_test_folder/data" }

      before do
        allow(Sensemaker::Paths).to receive(:sensemaker_data_folder).and_return(data_folder)
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

      context "when script is runner.ts" do
        let(:job) { create(:sensemaker_job, script: "runner.ts") }

        it "cleans up all runner summary output files" do
          expect(FileUtils).to receive(:rm_f).with("#{data_folder}/output-#{job.id}-summary.json")
          expect(FileUtils).to receive(:rm_f).with("#{data_folder}/output-#{job.id}-summary.html")
          expect(FileUtils).to receive(:rm_f).with("#{data_folder}/output-#{job.id}-summary.md")
          expect(FileUtils).to receive(:rm_f).with("#{data_folder}/output-#{job.id}-summaryAndSource.csv")

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
    describe "before_save :set_persisted_output_if_successful" do
      let(:data_folder) { "/tmp/sensemaker_test_folder/data" }

      before do
        allow(Sensemaker::Paths).to receive(:sensemaker_data_folder).and_return(data_folder)
        allow(File).to receive(:exist?).and_return(false)
      end

      context "when job is successful (finished_at present, no error)" do
        context "when persisted_output is not set" do
          context "when all output files exist" do
            it "sets persisted_output to default_output_path" do
              job.script = "categorization_runner.ts"
              output_path = "#{data_folder}/categorization-output-#{job.id}.csv"
              allow(File).to receive(:exist?).with(output_path).and_return(true)

              job.finished_at = Time.current
              job.error = nil
              job.save!

              expect(job.persisted_output).to eq(job.default_output_path)
            end

            it "sets persisted_output for advanced_runner.ts when all files exist" do
              job.script = "advanced_runner.ts"
              base_path = "#{data_folder}/output-#{job.id}"
              allow(File).to receive(:exist?).with("#{base_path}-summary.json").and_return(true)
              allow(File).to receive(:exist?).with("#{base_path}-topic-stats.json").and_return(true)
              allow(File).to receive(:exist?).with("#{base_path}-comments-with-scores.json").and_return(true)

              job.finished_at = Time.current
              job.error = nil
              job.save!

              expect(job.persisted_output).to eq(job.default_output_path)
            end

            it "sets persisted_output for runner.ts when all files exist" do
              job.script = "runner.ts"
              base_path = "#{data_folder}/output-#{job.id}"
              allow(File).to receive(:exist?).with("#{base_path}-summary.json").and_return(true)
              allow(File).to receive(:exist?).with("#{base_path}-summary.html").and_return(true)
              allow(File).to receive(:exist?).with("#{base_path}-summary.md").and_return(true)
              allow(File).to receive(:exist?).with("#{base_path}-summaryAndSource.csv").and_return(true)

              job.finished_at = Time.current
              job.error = nil
              job.save!

              expect(job.persisted_output).to eq(job.default_output_path)
            end
          end

          context "when not all output files exist" do
            it "does not set persisted_output" do
              job.script = "advanced_runner.ts"
              base_path = "#{data_folder}/output-#{job.id}"
              allow(File).to receive(:exist?).with("#{base_path}-summary.json").and_return(true)
              allow(File).to receive(:exist?).with("#{base_path}-topic-stats.json").and_return(true)
              allow(File).to receive(:exist?).with("#{base_path}-comments-with-scores.json").and_return(false)

              job.finished_at = Time.current
              job.error = nil
              job.save!

              expect(job.persisted_output).to be(nil)
            end
          end
        end

        context "when persisted_output is already set" do
          it "does not overwrite existing persisted_output" do
            existing_path = "/existing/path/output-#{job.id}"
            job.persisted_output = existing_path

            job.finished_at = Time.current
            job.error = nil
            job.save!

            expect(job.persisted_output).to eq(existing_path)
          end
        end
      end

      context "when job is not finished" do
        it "does not set persisted_output" do
          job.finished_at = nil
          job.error = nil
          job.save!

          expect(job.persisted_output).to be(nil)
        end
      end

      context "when job has an error" do
        it "does not set persisted_output" do
          job.finished_at = Time.current
          job.error = "Some error occurred"
          job.save!

          expect(job.persisted_output).to be(nil)
        end
      end
    end

    describe "after_destroy" do
      let(:data_folder) { "/tmp/sensemaker_test_folder/data" }

      before do
        allow(Sensemaker::Paths).to receive(:sensemaker_data_folder).and_return(data_folder)
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
