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

  shared_context "sensemaker paths stubbed" do
    let(:data_folder) { "/tmp/sensemaker_test_folder/data" }

    before do
      allow(Sensemaker::Paths).to receive(:sensemaker_data_folder).and_return(data_folder)
    end
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
      {
        "categorization_runner.ts" => ->(j) { "categorization-output-#{j.id}.csv" },
        "advanced_runner.ts" => ->(j) { "output-#{j.id}" },
        "runner.ts" => ->(j) { "output-#{j.id}" },
        "health_check_runner.ts" => ->(j) { "health-check-#{j.id}.txt" },
        "single-html-build.js" => ->(j) { "report-#{j.id}.html" }
      }.each do |script, expected_fn|
        it "returns the correct output file name for #{script}" do
          job.script = script
          expect(job.output_file_name).to eq(expected_fn.call(job))
        end
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
      include_context "sensemaker paths stubbed"

      {
        "categorization_runner.ts" => ->(j, df) { "#{df}/categorization-output-#{j.id}.csv" },
        "advanced_runner.ts" => ->(j, df) { "#{df}/output-#{j.id}" },
        "runner.ts" => ->(j, df) { "#{df}/output-#{j.id}" }
      }.each do |script, expected_path_fn|
        it "returns the correct path for #{script}" do
          job.script = script
          expect(job.default_output_path).to eq(expected_path_fn.call(job, data_folder))
        end
      end
    end

    describe "#relative_output_path" do
      let(:relative_data_folder) { "tmp/sensemaker_test_folder/data" }

      before do
        allow(Sensemaker::Paths).to receive(:sensemaker_relative_data_folder).and_return(relative_data_folder)
      end

      it "returns a path relative to Rails.root (no leading slash)" do
        job.script = "categorization_runner.ts"
        path = job.relative_output_path
        expect(path).to eq("#{relative_data_folder}/categorization-output-#{job.id}.csv")
        expect(path).not_to start_with("/")
      end

      {
        "advanced_runner.ts" => ->(j, rel_df) { "#{rel_df}/output-#{j.id}" },
        "single-html-build.js" => ->(j, rel_df) { "#{rel_df}/report-#{j.id}.html" }
      }.each do |script, expected_path_fn|
        it "returns the correct relative path for #{script}" do
          job.script = script
          expect(job.relative_output_path).to eq(expected_path_fn.call(job, relative_data_folder))
        end
      end
    end

    describe "#persisted_output_path" do
      [nil, ""].each do |blank_value|
        it "returns nil when persisted_output is #{blank_value.inspect}" do
          job.persisted_output = blank_value
          expect(job.persisted_output_path).to be(nil)
        end
      end

      it "resolves relative persisted_output against Rails.root so path survives deploys" do
        relative_path = "tmp/sensemaker_test_folder/data/output-60"
        job.persisted_output = relative_path
        expect(job.persisted_output_path).to eq(Rails.root.join(relative_path))
        expect(job.persisted_output_path.to_s).to include(Rails.root.to_s)
      end
    end

    describe "#output_artifact_paths" do
      include_context "sensemaker paths stubbed"
      let(:base_path) { "#{data_folder}/output-#{job.id}" }

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

        it "uses resolved persisted_output_path (absolute) so File.exist? works after deploys" do
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

        context "when persisted_output is a relative path (post-deploy safe)" do
          let(:relative_path) { "vendor/sensemaking-tools/data/output-#{job.id}" }

          before do
            job.persisted_output = relative_path
          end

          it "returns absolute paths via persisted_output_path so has_outputs? can find files" do
            job.script = "categorization_runner.ts"
            expected = Rails.root.join(relative_path).to_s
            expect(job.output_artifact_paths).to eq([expected])
          end
        end
      end
    end

    describe "#has_outputs?" do
      include_context "sensemaker paths stubbed"

      before do
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

      shared_examples "has_outputs for multi-output script" do |script_name, path_suffixes|
        before { job.script = script_name }

        it "returns true when all output files exist" do
          base_path = "#{data_folder}/output-#{job.id}"
          path_suffixes.each do |suffix|
            allow(File).to receive(:exist?).with("#{base_path}#{suffix}").and_return(true)
          end
          expect(job.has_outputs?).to be true
        end

        it "returns false when not all output files exist" do
          base_path = "#{data_folder}/output-#{job.id}"
          path_suffixes[0..-2].each do |suffix|
            allow(File).to receive(:exist?).with("#{base_path}#{suffix}").and_return(true)
          end
          allow(File).to receive(:exist?).with("#{base_path}#{path_suffixes.last}").and_return(false)
          expect(job.has_outputs?).to be false
        end
      end

      it_behaves_like "has_outputs for multi-output script",
                      "advanced_runner.ts",
                      %w[-summary.json -topic-stats.json -comments-with-scores.json]

      it_behaves_like "has_outputs for multi-output script",
                      "runner.ts",
                      %w[-summary.json -summary.html -summary.md -summaryAndSource.csv]
    end

    describe "#cleanup_associated_files" do
      include_context "sensemaker paths stubbed"

      before do
        allow(FileUtils).to receive(:rm_f).and_return(true)
        allow(Rails.logger).to receive(:info)
        allow(Rails.logger).to receive(:warn)
      end

      it "cleans up input files" do
        expect(FileUtils).to receive(:rm_f).with("#{data_folder}/input-#{job.id}.csv")
        expect(FileUtils).to receive(:rm_f).with("#{data_folder}/input-#{job.id}.csv.unfiltered")

        job.send(:cleanup_input_files, data_folder)
      end

      {
        "health_check_runner.ts" => ->(j, df) { ["#{df}/health-check-#{j.id}.txt"] },
        "advanced_runner.ts" => ->(j, df) {
          ["#{df}/output-#{j.id}-summary.json", "#{df}/output-#{j.id}-topic-stats.json",
           "#{df}/output-#{j.id}-comments-with-scores.json"]
        },
        "categorization_runner.ts" => ->(j, df) { ["#{df}/categorization-output-#{j.id}.csv"] },
        "single-html-build.js" => ->(j, df) { ["#{df}/report-#{j.id}.html"] },
        "runner.ts" => ->(j, df) {
          ["#{df}/output-#{j.id}-summary.json", "#{df}/output-#{j.id}-summary.html",
           "#{df}/output-#{j.id}-summary.md", "#{df}/output-#{j.id}-summaryAndSource.csv"]
        }
      }.each do |script, paths_fn|
        context "when script is #{script}" do
          it "cleans up output files" do
            job.script = script
            paths = paths_fn.call(job, data_folder)
            paths.each { |p| expect(FileUtils).to receive(:rm_f).with(p) }
            job.send(:cleanup_output_files, data_folder)
          end
        end
      end

      describe "#cleanup_persisted_output" do
        context "when persisted_output is present and file exists" do
          before do
            job.persisted_output = "/path/to/output.txt"
            allow(File).to receive(:exist?).and_return(false)
            allow(File).to receive(:exist?).with(Rails.root.join("/path/to/output.txt")).and_return(true)
          end

          it "removes the persisted output file using resolved path (persisted_output_path)" do
            resolved = Rails.root.join("/path/to/output.txt")
            expect(FileUtils).to receive(:rm_f).with(resolved)

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
      include_context "sensemaker paths stubbed"

      before do
        allow(File).to receive(:exist?).and_return(false)
      end

      shared_examples "sets persisted_output when all output files exist" do |script_name, paths_fn|
        it "sets persisted_output to relative_output_path for #{script_name} so path survives deploys" do
          job.script = script_name
          paths = paths_fn.call(job, data_folder)
          paths.each { |p| allow(File).to receive(:exist?).with(p).and_return(true) }

          job.finished_at = Time.current
          job.error = nil
          job.save!

          expect(job.persisted_output).to eq(job.relative_output_path)
          expect(job.persisted_output).not_to start_with("/")
        end
      end

      context "when job is successful (finished_at present, no error)" do
        context "when persisted_output is not set" do
          context "when all output files exist" do
            it_behaves_like "sets persisted_output when all output files exist",
                            "categorization_runner.ts",
                            ->(j, df) { ["#{df}/categorization-output-#{j.id}.csv"] }

            it_behaves_like "sets persisted_output when all output files exist",
                            "advanced_runner.ts",
                            ->(j, df) {
                              ["#{df}/output-#{j.id}-summary.json", "#{df}/output-#{j.id}-topic-stats.json",
                               "#{df}/output-#{j.id}-comments-with-scores.json"]
                            }

            it_behaves_like "sets persisted_output when all output files exist",
                            "runner.ts",
                            ->(j, df) {
                              ["#{df}/output-#{j.id}-summary.json", "#{df}/output-#{j.id}-summary.html",
                               "#{df}/output-#{j.id}-summary.md", "#{df}/output-#{j.id}-summaryAndSource.csv"]
                            }
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
      include_context "sensemaker paths stubbed"

      before do
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
