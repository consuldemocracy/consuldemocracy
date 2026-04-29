# frozen_string_literal: true

require "rails_helper"

describe Sensemaker::Backend::Node do
  include_context "sensemaker llm config"

  let(:user) { create(:user) }
  let(:runtime_config) do
    Sensemaker::RuntimeConfig.new(setting: Setting, llm_context: Llm::Config.context)
  end
  let(:backend) do
    Sensemaker::Backend::Node.new(job, runtime_config: runtime_config)
  end
  let(:debate) { create(:debate) }
  let(:job) do
    create(:sensemaker_job,
           analysable_type: "Debate",
           analysable_id: debate.id,
           script: "categorization_runner.ts",
           user: user,
           started_at: Time.current,
           additional_context: "")
  end

  describe "#build_command" do
    before do
      allow(Llm::Config).to receive(:context).and_return(llm_context)
      allow(Setting).to receive(:[]).and_call_original
      allow(Setting).to receive(:[]).with("llm.provider").and_return("VertexAI")
      allow(Setting).to receive(:[]).with("llm.model").and_return("gemini-2.5-flash-lite")
    end

    shared_examples "runner command with common flags" do |script_name, use_output_file_flag: true|
      it "returns the correct command for #{script_name}" do
        job.script = script_name
        command = backend.build_command
        expect(command).to include("npx ts-node #{backend.script_path}")
        expect(command).to include("--adapter vertex")
        expect(command).to include("--vertexProject sensemaker-466109")
        expect(command).to include("--vertexLocation global")
        expect(command).to include("--modelName gemini-2.5-flash-lite")
        expect(command).not_to include("--keyFilename")
        expect(command).not_to include("--baseUrl")
        expect(command).to include("--inputFile #{job.artefacts.input_path}")
        if use_output_file_flag
          expect(command).to include("--outputFile #{backend.send(:output_file)}")
        else
          expect(command).not_to include("--outputFile")
          expect(command).to include("--outputBasename #{backend.send(:output_file)}")
        end
      end
    end

    it_behaves_like "runner command with common flags", "categorization_runner.ts", use_output_file_flag: true
    it_behaves_like "runner command with common flags", "advanced_runner.ts", use_output_file_flag: false
    it_behaves_like "runner command with common flags", "runner.ts", use_output_file_flag: false

    it "returns the correct command for OpenAI-compatible providers" do
      allow(Setting).to receive(:[]).with("llm.provider").and_return("OpenAI")

      command = backend.build_command
      expect(command).to include("--adapter openai-compatible")
      expect(command).to include("--provider openai")
      expect(command).to include("--apiKey openai-secret")
      expect(command).to include("--baseUrl https://openai-proxy.example.com/v1")
      expect(command).not_to include("--vertexProject")
      expect(command).not_to include("--vertexLocation")
    end

    it "omits baseUrl for OpenAI-compatible providers when not configured" do
      allow(Setting).to receive(:[]).with("llm.provider").and_return("OpenAI")
      allow(llm_config).to receive(:openai_api_base).and_return(nil)

      command = backend.build_command
      expect(command).not_to include("--baseUrl")
    end

    it "returns the correct command for ollama provider" do
      allow(Setting).to receive(:[]).with("llm.provider").and_return("ollama")

      command = backend.build_command
      expect(command).to include("--adapter ollama")
      expect(command).to include("--baseUrl http://localhost:11434")
      expect(command).not_to include("--provider")
      expect(command).not_to include("--apiKey")
      expect(command).not_to include("--vertexProject")
    end

    it "returns the correct command for the sensemaking-report-ui script" do
      job.update!(script: "sensemaking-report-ui")
      conversation = instance_double(Sensemaker::Conversation)
      allow(job).to receive(:conversation).and_return(conversation)
      allow(conversation).to receive(:target_label).with(format: :full).and_return("Test Label")

      command = backend.build_command
      input_path = job.artefacts.input_path

      expect(command).to include("npx sensemaking-report-ui inline")
      expect(command).to include("--topics")
      expect(command).to include("#{input_path}-topic-stats.json")
      expect(command).to include("--summary")
      expect(command).to include("#{input_path}-summary.json")
      expect(command).to include("--comments")
      expect(command).to include("#{input_path}-comments-with-scores.json")
      expect(command).to include("--metadata")
      expect(command).to include(job.artefacts.metadata_path)
      expect(command).to include(Shellwords.escape("Report for Test Label"))
      expect(command).to include("--outputDir #{Shellwords.escape(job.artefacts.job_directory.to_s)}")
      expect(command).to include("--outputFile")
      expect(command).to include("report.html")
      expect(backend.output_file_name).to eq("report.html")
    end
  end

  describe "#script_path" do
    package_folder = Sensemaker::Paths.sensemaker_package_folder
    runner_cli = "#{package_folder}/runner-cli"
    report_ui = "/tmp/sensemaker_test_folder/report-ui"

    before do
      allow(Sensemaker::Paths).to receive(:report_ui_folder).and_return(report_ui)
    end

    {
      "categorization_runner.ts" => "#{runner_cli}/categorization_runner.ts",
      "runner.ts" => "#{runner_cli}/runner.ts",
      "advanced_runner.ts" => "#{runner_cli}/advanced_runner.ts",
      "health_check_runner.ts" => "#{runner_cli}/health_check_runner.ts",
      "sensemaking-report-ui" => "#{report_ui}/bin/cli.js"
    }.each do |script, expected_path|
      it "returns the correct path for #{script}" do
        job.script = script
        expect(backend.script_path).to eq(expected_path)
      end
    end
  end

  describe "#check_runtime_dependencies?" do
    before do
      allow(backend).to receive(:system).with("which node > /dev/null 2>&1").and_return(true)
      allow(backend).to receive(:system).with("which npx > /dev/null 2>&1").and_return(true)
      allow(File).to receive(:exist?).and_return(true)
    end

    it "returns true when all runtime dependencies are available" do
      expect(backend.check_runtime_dependencies?).to be true
    end

    {
      "Node.js is not available" => [
        -> { allow(backend).to receive(:system).with("which node > /dev/null 2>&1").and_return(false) },
        "Node.js not found"
      ],
      "NPX is not available" => [
        -> { allow(backend).to receive(:system).with("which npx > /dev/null 2>&1").and_return(false) },
        "NPX not found"
      ],
      "the sensemaking-tools package folder does not exist" => [
        -> {
          allow(File).to receive(:exist?).with(Sensemaker::Paths.sensemaker_package_folder).and_return(false)
        },
        "sensemaking-tools package folder not found"
      ],
      "the sensemaking data folder does not exist" => [
        -> {
          allow(File).to receive(:exist?).with(Sensemaker::Paths.sensemaker_data_folder).and_return(false)
        },
        "Sensemaker data folder not found"
      ],
      "the input file does not exist" => [
        -> {
          allow(File).to receive(:exist?).with(Sensemaker::Paths.sensemaker_package_folder).and_return(true)
          allow(File).to receive(:exist?).with(job.artefacts.input_path).and_return(false)
        },
        "Input file not found"
      ],
      "the script file does not exist" => [
        -> {
          allow(File).to receive(:exist?).with(Sensemaker::Paths.sensemaker_package_folder).and_return(true)
          allow(File).to receive(:exist?).with(job.artefacts.input_path).and_return(true)
          allow(File).to receive(:exist?).with(backend.script_path).and_return(false)
        },
        "Script file not found"
      ]
    }.each do |description, (setup, error_substring)|
      it "returns false when #{description}" do
        instance_exec(&setup)
        result = backend.check_runtime_dependencies?
        expect(result).to be false
        job.reload
        expect(job.finished_at).to be_present
        expect(job.error).to include(error_substring)
      end
    end
  end

  describe "#working_directory" do
    it "returns the sensemaker package folder for runner scripts" do
      expect(backend.working_directory).to eq(Sensemaker::Paths.sensemaker_package_folder)
    end

    it "returns Rails.root for the report-ui script" do
      job.update!(script: "sensemaking-report-ui")
      expect(backend.working_directory).to eq(Rails.root)
    end
  end

  describe "#after_input_prepared" do
    it "returns nil for standard runner scripts" do
      job.script = "categorization_runner.ts"
      expect(backend.after_input_prepared).to be(nil)
    end

    context "when script is advanced_runner.ts" do
      before do
        job.script = "advanced_runner.ts"
        job.input_file = "/tmp/categorization-output.csv"
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(job.artefacts.input_path).and_return(true)
      end

      it "calls provide_defaults_for_zero_vote_comments" do
        expect(Sensemaker::CsvExporter).to receive(:provide_defaults_for_zero_vote_comments)
          .with(job.artefacts.input_path).and_return(3)
        expect(backend.after_input_prepared).to eq(3)
      end
    end

    context "when script is sensemaking-report-ui" do
      before do
        job.update!(script: "sensemaking-report-ui")
        conversation = instance_double(Sensemaker::Conversation)
        allow(job).to receive(:conversation).and_return(conversation)
        allow(conversation).to receive(:target_label).with(format: :full).and_return("Test Label")
      end

      it "writes report metadata when file does not exist" do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(job.artefacts.metadata_path).and_return(false)
        allow(File).to receive(:write)

        backend.after_input_prepared

        expect(File).to have_received(:write).with(job.artefacts.metadata_path, anything)
      end

      it "skips writing metadata when file already exists" do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(job.artefacts.metadata_path).and_return(true)
        allow(File).to receive(:write)

        backend.after_input_prepared

        expect(File).not_to have_received(:write)
      end
    end
  end

  describe "#redact_command" do
    it "redacts api keys in commands" do
      command = "npx ts-node script.ts --apiKey super-secret-key"
      expect(backend.redact_command(command)).to include("--apiKey [REDACTED]")
      expect(backend.redact_command(command)).not_to include("super-secret-key")
    end
  end
end
