require "rails_helper"

describe Sensemaker::JobArtefacts do
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
  let(:artefacts) { Sensemaker::JobArtefacts.new(job) }

  shared_context "sensemaker paths stubbed" do
    let(:data_folder) { "/tmp/sensemaker_test_folder/data" }

    before do
      allow(Sensemaker::Paths).to receive(:sensemaker_data_folder).and_return(data_folder)
    end
  end

  describe "#output_file_name" do
    {
      "categorization_runner.ts" => ->(j) { "categorization-output-#{j.id}.csv" },
      "advanced_runner.ts" => ->(j) { "output-#{j.id}" },
      "runner.ts" => ->(j) { "output-#{j.id}" },
      "health_check_runner.ts" => ->(j) { "health-check-#{j.id}.txt" },
      "sensemaking-report-ui" => ->(j) { "report-#{j.id}.html" }
    }.each do |script, expected_fn|
      it "returns the correct output file name for #{script}" do
        job.script = script
        expect(artefacts.output_file_name).to eq(expected_fn.call(job))
      end
    end

    it "falls back for unknown scripts" do
      job.script = "unknown_runner.ts"
      expect(artefacts.output_file_name).to eq("output-#{job.id}.csv")
    end
  end

  describe "#multiple_outputs?" do
    it "returns true for advanced_runner.ts and runner.ts" do
      job.script = "advanced_runner.ts"
      expect(artefacts.multiple_outputs?).to be true
      job.script = "runner.ts"
      expect(artefacts.multiple_outputs?).to be true
    end

    it "returns false for single output scripts" do
      job.script = "categorization_runner.ts"
      expect(artefacts.multiple_outputs?).to be false
      job.script = "health_check_runner.ts"
      expect(artefacts.multiple_outputs?).to be false
      job.script = "sensemaking-report-ui"
      expect(artefacts.multiple_outputs?).to be false
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
        expect(artefacts.default_output_path).to eq(expected_path_fn.call(job, data_folder))
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
      path = artefacts.relative_output_path
      expect(path).to eq("#{relative_data_folder}/categorization-output-#{job.id}.csv")
      expect(path).not_to start_with("/")
    end

    {
      "advanced_runner.ts" => ->(j, rel_df) { "#{rel_df}/output-#{j.id}" },
      "sensemaking-report-ui" => ->(j, rel_df) { "#{rel_df}/report-#{j.id}.html" }
    }.each do |script, expected_path_fn|
      it "returns the correct relative path for #{script}" do
        job.script = script
        expect(artefacts.relative_output_path).to eq(expected_path_fn.call(job, relative_data_folder))
      end
    end
  end

  describe "#persisted_output_path" do
    [nil, ""].each do |blank_value|
      it "returns nil when persisted_output is #{blank_value.inspect}" do
        job.persisted_output = blank_value
        expect(artefacts.persisted_output_path).to be(nil)
      end
    end

    it "resolves relative persisted_output against Rails.root so path survives deploys" do
      relative_path = "tmp/sensemaker_test_folder/data/output-60"
      job.persisted_output = relative_path
      expect(artefacts.persisted_output_path).to eq(Rails.root.join(relative_path))
      expect(artefacts.persisted_output_path.to_s).to include(Rails.root.to_s)
    end
  end

  describe "#output_artefact_paths" do
    include_context "sensemaker paths stubbed"
    let(:base_path) { "#{data_folder}/output-#{job.id}" }

    context "when persisted_output is not set" do
      it "uses default_output_path for single output scripts" do
        job.script = "categorization_runner.ts"
        expected_path = "#{data_folder}/categorization-output-#{job.id}.csv"
        expect(artefacts.output_artefact_paths).to eq([expected_path])
      end

      it "uses default_output_path for advanced_runner.ts" do
        job.script = "advanced_runner.ts"
        expect(artefacts.output_artefact_paths).to eq([
          "#{base_path}-summary.json",
          "#{base_path}-topic-stats.json",
          "#{base_path}-comments-with-scores.json"
        ])
      end

      it "uses default_output_path for runner.ts" do
        job.script = "runner.ts"
        expect(artefacts.output_artefact_paths).to eq([
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
        expect(artefacts.output_artefact_paths).to eq([persisted_path])
      end

      it "uses persisted_output for advanced_runner.ts" do
        job.script = "advanced_runner.ts"
        expect(artefacts.output_artefact_paths).to eq([
          "#{persisted_path}-summary.json",
          "#{persisted_path}-topic-stats.json",
          "#{persisted_path}-comments-with-scores.json"
        ])
      end

      it "uses persisted_output for runner.ts" do
        job.script = "runner.ts"
        expect(artefacts.output_artefact_paths).to eq([
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

        it "returns absolute paths via persisted_output_path so complete? can find files" do
          job.script = "categorization_runner.ts"
          expected = Rails.root.join(relative_path).to_s
          expect(artefacts.output_artefact_paths).to eq([expected])
        end
      end
    end
  end

  describe "#complete?" do
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
        expect(artefacts.complete?).to be true
      end

      it "returns false when the output file does not exist" do
        expect(artefacts.complete?).to be false
      end
    end

    shared_examples "complete for multi-output script" do |script_name, path_suffixes|
      before { job.script = script_name }

      it "returns true when all output files exist" do
        base_path = "#{data_folder}/output-#{job.id}"
        path_suffixes.each do |suffix|
          allow(File).to receive(:exist?).with("#{base_path}#{suffix}").and_return(true)
        end
        expect(artefacts.complete?).to be true
      end

      it "returns false when not all output files exist" do
        base_path = "#{data_folder}/output-#{job.id}"
        path_suffixes[0..-2].each do |suffix|
          allow(File).to receive(:exist?).with("#{base_path}#{suffix}").and_return(true)
        end
        allow(File).to receive(:exist?).with("#{base_path}#{path_suffixes.last}").and_return(false)
        expect(artefacts.complete?).to be false
      end
    end

    it_behaves_like "complete for multi-output script",
                    "advanced_runner.ts",
                    %w[-summary.json -topic-stats.json -comments-with-scores.json]

    it_behaves_like "complete for multi-output script",
                    "runner.ts",
                    %w[-summary.json -summary.html -summary.md -summaryAndSource.csv]
  end

  describe "#input_path" do
    include_context "sensemaker paths stubbed"

    it "returns the stored input_file when set" do
      job[:input_file] = "/custom/input.csv"
      expect(artefacts.input_path).to eq("/custom/input.csv")
    end

    it "defaults to categorization output for advanced_runner.ts when input_file is not set" do
      job.script = "advanced_runner.ts"
      job[:input_file] = nil
      expect(artefacts.input_path).to eq("#{data_folder}/categorization-output-#{job.id}.csv")
    end

    it "defaults to advanced-output for report script when input_file is not set" do
      job.script = "sensemaking-report-ui"
      job[:input_file] = nil
      expect(artefacts.input_path).to eq("#{data_folder}/advanced-output")
    end

    it "defaults to input csv for other scripts when input_file is not set" do
      job.script = "runner.ts"
      job[:input_file] = nil
      expect(artefacts.input_path).to eq("#{data_folder}/input-#{job.id}.csv")
    end
  end

  describe "#input_artefact_paths" do
    include_context "sensemaker paths stubbed"

    it "returns an empty array when input_path is blank" do
      job.script = "health_check_runner.ts"
      job[:input_file] = nil
      expect(artefacts.input_artefact_paths).to eq([])
    end

    it "returns a single path for single-input scripts" do
      job.script = "runner.ts"
      job[:input_file] = "/tmp/input-#{job.id}.csv"
      expect(artefacts.input_artefact_paths).to eq([job[:input_file]])
    end

    it "returns derived JSON artefacts for sensemaking-report-ui" do
      job.script = "sensemaking-report-ui"
      job[:input_file] = "/tmp/output-#{job.id}"

      expect(artefacts.input_artefact_paths).to eq([
        "#{job[:input_file]}-topic-stats.json",
        "#{job[:input_file]}-summary.json",
        "#{job[:input_file]}-comments-with-scores.json",
        "#{job[:input_file]}-metadata.json"
      ])
    end
  end

  describe "#metadata_path" do
    it "returns nil when input_path is blank" do
      job.script = "health_check_runner.ts"
      job[:input_file] = nil
      expect(artefacts.metadata_path).to be(nil)
    end

    it "returns the metadata json path derived from input_path" do
      job[:input_file] = "/tmp/output-#{job.id}"
      expect(artefacts.metadata_path).to eq("/tmp/output-#{job.id}-metadata.json")
    end
  end

  describe "#existing_output_artefact_paths" do
    include_context "sensemaker paths stubbed"
    let(:base_path) { "#{data_folder}/output-#{job.id}" }

    before do
      allow(File).to receive(:exist?).and_return(false)
    end

    it "returns only paths for which the file exists" do
      job.script = "runner.ts"
      existing_path = "#{base_path}-summary.json"
      allow(File).to receive(:exist?).with(existing_path).and_return(true)

      expect(artefacts.existing_output_artefact_paths).to eq([existing_path])
    end

    it "excludes paths for which the file does not exist" do
      job.script = "runner.ts"
      path1 = "#{base_path}-summary.json"
      path2 = "#{base_path}-summary.html"
      allow(File).to receive(:exist?).with(path1).and_return(true)
      allow(File).to receive(:exist?).with(path2).and_return(false)

      expect(artefacts.existing_output_artefact_paths).to eq([path1])
    end
  end

  describe "#existing_input_artefact_paths" do
    before do
      allow(File).to receive(:exist?).and_return(false)
    end

    it "returns only input artefacts that exist" do
      existing_path = "/tmp/input-existing-#{job.id}.csv"
      allow(File).to receive(:exist?).with(existing_path).and_return(true)
      job.script = "runner.ts"
      job[:input_file] = existing_path

      expect(artefacts.existing_input_artefact_paths).to eq([existing_path])
    end

    it "returns only existing derived input artefacts for sensemaking-report-ui" do
      job.script = "sensemaking-report-ui"
      job[:input_file] = "/tmp/output-#{job.id}"
      existing = "#{job[:input_file]}-summary.json"
      missing_1 = "#{job[:input_file]}-topic-stats.json"
      missing_2 = "#{job[:input_file]}-comments-with-scores.json"
      missing_3 = "#{job[:input_file]}-metadata.json"

      allow(File).to receive(:exist?).with(existing).and_return(true)
      allow(File).to receive(:exist?).with(missing_1).and_return(false)
      allow(File).to receive(:exist?).with(missing_2).and_return(false)
      allow(File).to receive(:exist?).with(missing_3).and_return(false)

      expect(artefacts.existing_input_artefact_paths).to eq([existing])
    end
  end

  describe "#cleanup" do
    include_context "sensemaker paths stubbed"

    before do
      allow(FileUtils).to receive(:rm_f).and_return(true)
    end

    it "cleans up default input csv and unfiltered sidecar" do
      expect(FileUtils).to receive(:rm_f).with("#{data_folder}/input-#{job.id}.csv").at_least(:once)
      expect(FileUtils).to receive(:rm_f).with("#{data_folder}/input-#{job.id}.csv.unfiltered")

      artefacts.cleanup
    end

    {
      "health_check_runner.ts" => ->(j, df) { ["#{df}/health-check-#{j.id}.txt"] },
      "advanced_runner.ts" => ->(j, df) {
        ["#{df}/output-#{j.id}-summary.json", "#{df}/output-#{j.id}-topic-stats.json",
         "#{df}/output-#{j.id}-comments-with-scores.json"]
      },
      "categorization_runner.ts" => ->(j, df) { ["#{df}/categorization-output-#{j.id}.csv"] },
      "sensemaking-report-ui" => ->(j, df) { ["#{df}/report-#{j.id}.html"] },
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
          artefacts.cleanup
        end
      end
    end

    context "when persisted_output is present and file exists" do
      before do
        job.persisted_output = "/path/to/output.txt"
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:exist?).with(Rails.root.join("/path/to/output.txt")).and_return(true)
      end

      it "removes the persisted output file using resolved path (persisted_output_path)" do
        resolved = Rails.root.join("/path/to/output.txt")
        expect(FileUtils).to receive(:rm_f).with(resolved)

        artefacts.cleanup
      end
    end

    context "when persisted_output is nil" do
      before do
        job.persisted_output = nil
      end

      it "does not attempt to remove a persisted output file" do
        expect(FileUtils).not_to receive(:rm_f).with("/path/to/output.txt")
        artefacts.cleanup
      end
    end

    it "handles errors gracefully" do
      allow(FileUtils).to receive(:rm_f).and_raise(StandardError.new("File system error"))

      expect(artefacts.cleanup).to be(nil)
    end
  end
end
