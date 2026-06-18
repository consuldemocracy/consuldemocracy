require "rails_helper"

describe Sensemaker::JobRunner do
  let(:user) { create(:user) }
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

  shared_context "sensemaker paths stubbed" do
    let(:data_folder) { "/tmp/sensemaker_test_folder/data" }
    let(:report_ui_folder) { "/tmp/sensemaker_test_folder/report-ui" }

    before do
      allow(Sensemaker::Paths).to receive_messages(
        sensemaker_data_folder: data_folder,
        report_ui_folder: report_ui_folder
      )
    end
  end

  describe "#initialize" do
    it "initializes with the provided job" do
      service = Sensemaker::JobRunner.new(job)
      expect(service.job).to eq(job)
    end
  end

  describe "#run" do
    let(:service) { Sensemaker::JobRunner.new(job) }

    before do
      FileUtils.mkdir_p(Sensemaker::Paths.sensemaker_package_folder)
      allow(File).to receive(:exist?).and_return(true)
      allow(service).to receive(:system).with("which node > /dev/null 2>&1").and_return(true)
      allow(service).to receive(:system).with("which npx > /dev/null 2>&1").and_return(true)
      allow(service).to receive(:check_dependencies?).and_return(true)
    end

    it "runs the complete workflow successfully" do
      allow(File).to receive(:exist?).and_return(true)
      allow(service).to receive(:system).and_return(true)

      service.run

      job.reload
      expect(job.started_at).to be_present
      expect(job.finished_at).to be_present
    end

    it "stops if check_dependencies? returns false" do
      allow(service).to receive(:check_dependencies?).and_return(false)
      expect(service).not_to receive(:execute_script)

      service.run
    end

    it "stops if execute_script returns false" do
      expect(service).to receive(:execute_script).and_return(false)

      service.run
    end

    it "handles errors and updates the job" do
      expect(service).to receive(:execute_script).and_raise(StandardError.new("Test error"))

      expect { service.run }.to raise_error(StandardError)

      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Test error")
    end
  end

  describe "#check_dependencies?" do
    let(:service) { Sensemaker::JobRunner.new(job) }
    let(:llm_config) do
      double(
        "LLM config",
        vertexai_project_id: "sensemaker-466109",
        vertexai_location: "global",
        openai_api_key: "openai-secret",
        openai_api_base: "https://openai-proxy.example.com/v1",
        together_api_base: "https://api.together.xyz/v1",
        mistral_api_base: "https://api.mistral.ai/v1",
        ollama_api_base: "http://localhost:11434",
        together_api_key: "together-secret",
        mistral_api_key: "mistral-secret"
      )
    end
    let(:llm_context) { double("LLM context", config: llm_config) }

    before do
      allow(service).to receive(:system).with("which node > /dev/null 2>&1").and_return(true)
      allow(service).to receive(:system).with("which npx > /dev/null 2>&1").and_return(true)
      allow(File).to receive(:exist?).and_return(true)
      allow(Llm::Config).to receive(:context).and_return(llm_context)
      allow(Setting).to receive(:[]).and_call_original
      allow(Setting).to receive(:[]).with("llm.provider").and_return("VertexAI")
      allow(Setting).to receive(:[]).with("llm.model").and_return("gemini-2.5-flash-lite")
    end

    it "returns true when all dependencies are available" do
      result = service.send(:check_dependencies?)
      expect(result).to be true
    end

    {
      "sensemaker_data_folder is not configured" => [
        -> { allow(Tenant.current_secrets).to receive(:sensemaker_data_folder).and_return(nil) },
        "Sensemaker data folder not configured"
      ],
      "Vertex AI project_id is not configured" => [
        -> { allow(llm_config).to receive(:vertexai_project_id).and_return(nil) },
        "Vertex AI is not configured"
      ],
      "LLM provider is unsupported" => [
        -> { allow(Setting).to receive(:[]).with("llm.provider").and_return("Unsupported") },
        "Sensemaker LLM provider is not supported"
      ],
      "LLM model is not selected" => [
        -> { allow(Setting).to receive(:[]).with("llm.model").and_return(nil) },
        "Sensemaker requires an LLM model to be selected"
      ],
      "Node.js is not available" => [
        -> { allow(service).to receive(:system).with("which node > /dev/null 2>&1").and_return(false) },
        "Node.js not found"
      ],
      "NPX is not available" => [
        -> { allow(service).to receive(:system).with("which npx > /dev/null 2>&1").and_return(false) },
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
          allow(File).to receive(:exist?).with(job.input_file).and_return(false)
        },
        "Input file not found"
      ],
      "apis.google_application_credentials is set but key file does not exist" => [
        -> {
          allow(Rails.application.secrets).to receive(:google_application_credentials)
          .and_return("/nonexistent/key.json")
          allow(File).to receive(:exist?).with("/nonexistent/key.json").and_return(false)
          allow(File).to receive(:exist?).with(Sensemaker::Paths.sensemaker_package_folder).and_return(true)
          allow(File).to receive(:exist?).with(job.input_file).and_return(true)
        },
        "Key file (apis.google_application_credentials) not found"
      ],
      "the script file does not exist" => [
        -> {
          allow(File).to receive(:exist?).with(Sensemaker::Paths.sensemaker_package_folder).and_return(true)
          allow(File).to receive(:exist?).with(job.input_file).and_return(true)
          allow(File).to receive(:exist?).with(service.script_file).and_return(false)
        },
        "Script file not found"
      ]
    }.each do |description, (setup, error_substring)|
      it "returns false when #{description}" do
        instance_exec(&setup)
        result = service.send(:check_dependencies?)
        expect(result).to be false
        job.reload
        expect(job.finished_at).to be_present
        expect(job.error).to include(error_substring)
      end
    end

    it "returns true for OpenAI-compatible provider with API key" do
      allow(Setting).to receive(:[]).with("llm.provider").and_return("OpenAI")
      allow(llm_config).to receive(:openai_api_key).and_return("tenant-openai-key")

      result = service.send(:check_dependencies?)
      expect(result).to be true
    end

    it "returns false for OpenAI-compatible provider without API key" do
      allow(Setting).to receive(:[]).with("llm.provider").and_return("OpenAI")
      allow(llm_config).to receive(:openai_api_key).and_return(nil)

      result = service.send(:check_dependencies?)
      expect(result).to be false
      job.reload
      expect(job.error).to include("Sensemaker requires an API key for provider 'openai'")
    end
  end

  describe "#execute_script" do
    let(:service) { Sensemaker::JobRunner.new(job) }

    before do
      allow(File).to receive(:exist?).and_return(true)
      allow(Setting).to receive(:[]).and_call_original
      allow(Setting).to receive(:[]).with("llm.provider").and_return("VertexAI")
      allow(Setting).to receive(:[]).with("llm.model").and_return("gemini-2.5-flash-lite")
    end

    it "returns value when the script executes successfully" do
      timeout = Sensemaker::JobRunner::TIMEOUT
      expected_command = %r{cd .* && timeout #{timeout} .*}
      expect(service).to receive(:`).with(expected_command).and_return("Success output")

      allow(service).to receive(:process_exit_status).and_return(0)

      result = service.send(:execute_script)

      expect(result).to be_present
    end

    it "returns nil and updates the job when the script fails" do
      timeout = Sensemaker::JobRunner::TIMEOUT
      expected_command = %r{cd .* && timeout #{timeout} .*}
      expect(service).to receive(:`).with(expected_command).and_return("Error output")

      allow(service).to receive(:process_exit_status).and_return(1)

      result = service.send(:execute_script)

      expect(result).to be nil

      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Command:")
      expect(job.error).to include("Error output")
    end

    it "redacts api keys in stored command errors" do
      timeout = Sensemaker::JobRunner::TIMEOUT
      expected_command = %r{cd .* && timeout #{timeout} .*--apiKey super-secret-key.*}
      expect(service).to receive(:`).with(expected_command).and_return("Error output")
      allow(service).to receive_messages(
        sensemaker_adapter: "openai-compatible",
        sensemaker_provider: "openai",
        sensemaker_api_key: "super-secret-key",
        process_exit_status: 1
      )

      service.send(:execute_script)
      job.reload
      expect(job.error).to include("--apiKey [REDACTED]")
      expect(job.error).not_to include("super-secret-key")
    end
  end

  describe "#build_command" do
    let(:service) { Sensemaker::JobRunner.new(job) }
    let(:llm_config) do
      double(
        "LLM config",
        vertexai_project_id: "sensemaker-466109",
        vertexai_location: "global",
        openai_api_key: "openai-secret",
        openai_api_base: "https://openai-proxy.example.com/v1",
        together_api_base: "https://api.together.xyz/v1",
        mistral_api_base: "https://api.mistral.ai/v1",
        ollama_api_base: "http://localhost:11434",
        together_api_key: "together-secret",
        mistral_api_key: "mistral-secret"
      )
    end
    let(:llm_context) { double("LLM context", config: llm_config) }

    before do
      allow(Llm::Config).to receive(:context).and_return(llm_context)
      allow(Setting).to receive(:[]).and_call_original
      allow(Setting).to receive(:[]).with("llm.provider").and_return("VertexAI")
      allow(Setting).to receive(:[]).with("llm.model").and_return("gemini-2.5-flash-lite")
    end

    shared_examples "runner command with common flags" do |script_name, use_output_file_flag: true|
      it "returns the correct command for #{script_name}" do
        service.job.script = script_name
        command = service.build_command
        expect(command).to include("npx ts-node #{service.script_file}")
        expect(command).to include("--adapter vertex")
        expect(command).to include("--vertexProject sensemaker-466109")
        expect(command).to include("--vertexLocation global")
        expect(command).to include("--modelName gemini-2.5-flash-lite")
        expect(command).not_to include("--keyFilename")
        expect(command).not_to include("--baseUrl")
        expect(command).to include("--inputFile #{job.input_file}")
        if use_output_file_flag
          expect(command).to include("--outputFile #{service.output_file}")
        else
          expect(command).not_to include("--outputFile")
          expect(command).to include("--outputBasename #{service.output_file}")
        end
      end
    end

    it_behaves_like "runner command with common flags", "categorization_runner.ts", use_output_file_flag: true
    it_behaves_like "runner command with common flags", "advanced_runner.ts", use_output_file_flag: false
    it_behaves_like "runner command with common flags", "runner.ts", use_output_file_flag: false

    it "returns the correct command for OpenAI-compatible providers" do
      allow(Setting).to receive(:[]).with("llm.provider").and_return("OpenAI")

      command = service.build_command
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

      command = service.build_command
      expect(command).not_to include("--baseUrl")
    end

    it "returns the correct command for ollama provider" do
      allow(Setting).to receive(:[]).with("llm.provider").and_return("ollama")

      command = service.build_command
      expect(command).to include("--adapter ollama")
      expect(command).to include("--baseUrl http://localhost:11434")
      expect(command).not_to include("--provider")
      expect(command).not_to include("--apiKey")
      expect(command).not_to include("--vertexProject")
    end

    it "returns the correct command for the sensemaking-report-ui script" do
      service.job.update!(script: "sensemaking-report-ui")
      allow(service.job.conversation).to receive(:target_label).with(format: :full).and_return("Test Label")

      command = service.build_command

      expect(command).to include("npx sensemaking-report-ui inline")
      expect(command).to include("--topics")
      expect(command).to include("#{job.input_file}-topic-stats.json")
      expect(command).to include("--summary")
      expect(command).to include("#{job.input_file}-summary.json")
      expect(command).to include("--comments")
      expect(command).to include("#{job.input_file}-comments-with-scores.json")
      expect(command).to include("--metadata")
      expect(command).to include("#{job.input_file}-metadata.json")
      expect(command).to include(Shellwords.escape("Report for Test Label"))
      expect(command).to include("--outputDir")
      expect(command).to include("--outputFile")
      expect(command).to include(service.output_file_name)
    end
  end

  describe "#script_file" do
    let(:service) { Sensemaker::JobRunner.new(job) }

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
        expect(service.script_file).to eq(expected_path)
      end
    end
  end

  describe "#execute_job_workflow" do
    let(:service) { Sensemaker::JobRunner.new(job) }
    include_context "sensemaker paths stubbed"

    before do
      allow(File).to receive(:exist?).and_return(true)
      allow(service).to receive(:system).with("which node > /dev/null 2>&1").and_return(true)
      allow(service).to receive(:system).with("which npx > /dev/null 2>&1").and_return(true)
      allow(service).to receive_messages(check_dependencies?: true, execute_script: "success")
      allow(service).to receive(:prepare_input_data)
    end

    context "when all output files exist" do
      it "sets finished_at and does not set error" do
        allow(job).to receive(:has_outputs?).and_return(true)

        service.send(:execute_job_workflow)

        job.reload
        expect(job.finished_at).to be_present
        expect(job.error).to be(nil)
      end

      it "sets comments_analysed count when job finishes successfully" do
        allow(job).to receive(:has_outputs?).and_return(true)
        allow(service).to receive(:prepare_input_data).and_return(5)

        service.send(:execute_job_workflow)

        job.reload
        expect(job.comments_analysed).to eq(5)
      end

      it "triggers the callback to set persisted_output (relative path for deploy safety)" do
        job.script = "categorization_runner.ts"
        output_path = "#{data_folder}/categorization-output-#{job.id}.csv"
        allow(File).to receive(:exist?).with(output_path).and_return(true)
        allow(job).to receive(:has_outputs?).and_return(true)

        service.send(:execute_job_workflow)

        job.reload
        expect(job.persisted_output).to eq(job.relative_output_path)
      end
    end

    context "when output files do not exist" do
      it "sets finished_at and error message" do
        allow(job).to receive(:has_outputs?).and_return(false)

        service.send(:execute_job_workflow)

        job.reload
        expect(job.finished_at).to be_present
        expect(job.error).to eq("Output file(s) not found")
      end

      it "does not set persisted_output" do
        allow(job).to receive(:has_outputs?).and_return(false)

        service.send(:execute_job_workflow)

        job.reload
        expect(job.persisted_output).to be(nil)
      end
    end

    shared_examples "checks all output files exist and sets persisted_output" do |script_name, path_suffixes|
      before do
        job.update!(script: script_name)
        allow(service).to receive_messages(check_dependencies?: true, execute_script: "success")
        allow(service).to receive(:prepare_input_data)
      end

      it "checks all output files exist" do
        base_path = "#{data_folder}/output-#{job.id}"
        path_suffixes.each do |suffix|
          allow(File).to receive(:exist?).with("#{base_path}#{suffix}").and_return(true)
        end

        service.send(:execute_job_workflow)

        job.reload
        expect(job.finished_at).to be_present
        expect(job.error).to be(nil)
        expect(job.persisted_output).to eq(job.relative_output_path)
      end
    end

    it_behaves_like "checks all output files exist and sets persisted_output",
                    "advanced_runner.ts",
                    %w[-summary.json -topic-stats.json -comments-with-scores.json]

    it_behaves_like "checks all output files exist and sets persisted_output",
                    "runner.ts",
                    %w[-summary.json -summary.html -summary.md -summaryAndSource.csv]
  end

  describe "#prepare_input_data" do
    let(:service) { Sensemaker::JobRunner.new(job) }
    let(:mock_exporter) { instance_double(Sensemaker::CsvExporter) }
    let(:input_file_path) { "#{Sensemaker::Paths.sensemaker_data_folder}/input-#{job.id}.csv" }
    let(:mock_conversation) { instance_double(Sensemaker::Conversation) }
    let(:mock_comments) { Array.new(7) { double("comment") } }

    before do
      allow(Sensemaker::CsvExporter).to receive(:new).and_return(mock_exporter)
      allow(mock_exporter).to receive(:export_to_csv)
      allow(job).to receive(:conversation).and_return(mock_conversation)
      allow(mock_conversation).to receive_messages(
        comments: mock_comments,
        compile_context: "Test context"
      )
    end

    it "creates a CsvExporter with the job's conversation" do
      service.send(:prepare_input_data)

      expect(Sensemaker::CsvExporter).to have_received(:new).with(mock_conversation)
    end

    it "exports CSV data to the input file" do
      service.send(:prepare_input_data)

      expect(mock_exporter).to have_received(:export_to_csv).with(input_file_path)
    end

    it "persists input_file after exporting CSV when input_file is blank" do
      expect(job.read_attribute(:input_file)).to be(nil)

      service.send(:prepare_input_data)

      expect(job.reload.input_file).to eq(input_file_path)
    end

    it "updates the job with additional context" do
      allow(job).to receive(:conversation).and_call_original

      service.send(:prepare_input_data)

      job.reload
      expect(job.additional_context).to be_present
      expect(job.additional_context).to include("Analysing Citizen debate")
      expect(job.additional_context).to include(debate.title)
    end

    it "returns the count of comments from conversation when input_file is blank" do
      job.input_file = nil
      result = service.send(:prepare_input_data)

      expect(result).to eq(7)
    end

    context "when script is advanced_runner.ts" do
      before do
        job.script = "advanced_runner.ts"
        job.input_file = "/tmp/categorization-output.csv"
        allow(File).to receive(:exist?).with(job.input_file).and_return(true)
      end

      it "calls CsvExporter.filter_zero_vote_comments_from_csv" do
        expect(Sensemaker::CsvExporter).to receive(:filter_zero_vote_comments_from_csv)
          .with(job.input_file).and_return(3)
        service.send(:prepare_input_data)
      end

      it "returns the filtered count from filter_zero_vote_comments_from_csv" do
        allow(Sensemaker::CsvExporter).to receive(:filter_zero_vote_comments_from_csv)
          .with(job.input_file).and_return(3)
        result = service.send(:prepare_input_data)

        expect(result).to eq(3)
      end
    end

    context "when script is advanced_runner.ts with blank input_file" do
      let(:categorization_job) { create(:sensemaker_job, comments_analysed: 10) }
      let(:categorization_runner) { instance_double(Sensemaker::JobRunner) }

      before do
        job.script = "advanced_runner.ts"
        job.input_file = nil
        allow(File).to receive(:exist?).with(job.input_file).and_return(true)
      end

      it "calls prepare_with_categorization_job and then filters the CSV" do
        allow(service).to receive(:prepare_with_categorization_job).and_return(10)
        allow(Sensemaker::CsvExporter).to receive(:filter_zero_vote_comments_from_csv)
          .with(job.input_file).and_return(8)

        result = service.send(:prepare_input_data)

        expect(result).to eq(8)
        expect(Sensemaker::CsvExporter).to have_received(:filter_zero_vote_comments_from_csv)
          .with(job.input_file)
      end
    end

    context "when script is sensemaking-report-ui with blank input_file" do
      let(:advanced_job) { create(:sensemaker_job, comments_analysed: 15) }

      before do
        job.script = "sensemaking-report-ui"
        job.input_file = nil
      end

      it "calls prepare_with_advanced_runner_job and returns its comments_analysed count" do
        allow(service).to receive(:prepare_with_advanced_runner_job).and_return(15)
        allow(service).to receive(:write_report_metadata)

        result = service.send(:prepare_input_data)

        expect(result).to eq(15)
        expect(service).to have_received(:write_report_metadata)
      end
    end

    context "when input_file is already set for non-advanced_runner script" do
      before do
        job.script = "categorization_runner.ts"
        job.input_file = "/existing/input.csv"
      end

      it "returns 0 when input_file is already set" do
        result = service.send(:prepare_input_data)

        expect(result).to eq(0)
      end

      it "does not export CSV when input_file is already set" do
        service.send(:prepare_input_data)

        expect(mock_exporter).not_to have_received(:export_to_csv)
      end
    end
  end
end
