require "rails_helper"

describe Sensemaker::JobRunner do
  include_context "sensemaker llm config"

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

  describe "#initialize" do
    it "initializes with the provided job" do
      service = Sensemaker::JobRunner.new(job)
      expect(service.job).to eq(job)
      expect(service.backend).to be_a(Sensemaker::Backend::Node)
    end
  end

  describe "#run" do
    let(:service) { Sensemaker::JobRunner.new(job) }

    before do
      FileUtils.mkdir_p(Sensemaker::Paths.sensemaker_package_folder)
      allow(File).to receive(:exist?).and_return(true)
      allow(service.backend).to receive(:check_runtime_dependencies?).and_return(true)
      allow(service).to receive_messages(check_dependencies?: true, prepare_input_data: 0)
    end

    it "runs the complete workflow successfully" do
      allow(File).to receive(:exist?).and_return(true)
      allow(service).to receive(:system).and_return(true)

      service.run_synchronously

      job.reload
      expect(job.started_at).to be_present
      expect(job.finished_at).to be_present
    end

    it "stops if check_dependencies? returns false" do
      allow(service).to receive(:check_dependencies?).and_return(false)
      expect(service).not_to receive(:execute_script)

      service.run_synchronously
    end

    it "stops if execute_script returns false" do
      expect(service).to receive(:execute_script).and_return(false)

      service.run_synchronously
    end

    it "handles errors and updates the job" do
      expect(service).to receive(:execute_script).and_raise(StandardError.new("Test error"))

      expect { service.run_synchronously }.to raise_error(StandardError)

      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Test error")
    end
  end

  describe "#check_dependencies?" do
    let(:service) { Sensemaker::JobRunner.new(job) }

    before do
      allow(Llm::Config).to receive(:context).and_return(llm_context)
      allow(Setting).to receive(:[]).and_call_original
      allow(Setting).to receive(:[]).with("llm.provider").and_return("VertexAI")
      allow(Setting).to receive(:[]).with("llm.model").and_return("gemini-2.5-flash-lite")
      allow(service.backend).to receive(:check_runtime_dependencies?).and_return(true)
      allow(File).to receive(:exist?).and_return(true)
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
      "apis.google_application_credentials is set but key file does not exist" => [
        -> {
          allow(Rails.application.secrets).to receive(:google_application_credentials)
          .and_return("/nonexistent/key.json")
          allow(File).to receive(:exist?).with("/nonexistent/key.json").and_return(false)
        },
        "Key file (apis.google_application_credentials) not found"
      ],
      "runtime dependencies check fails" => [
        -> {
          allow(service.backend).to receive(:check_runtime_dependencies?).and_return(false)
        },
        nil
      ]
    }.each do |description, (setup, error_substring)|
      it "returns false when #{description}" do
        instance_exec(&setup)
        result = service.send(:check_dependencies?)
        expect(result).to be false
        next if error_substring.nil?

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
      allow(Llm::Config).to receive(:context).and_return(llm_context)
      allow(llm_config).to receive(:openai_api_key).and_return("super-secret-key")
      allow(Setting).to receive(:[]).with("llm.provider").and_return("OpenAI")
      allow(Setting).to receive(:[]).with("llm.model").and_return("gpt-4o")

      timeout = Sensemaker::JobRunner::TIMEOUT
      expected_command = %r{cd .* && timeout #{timeout} .*--apiKey super-secret-key.*}
      expect(service).to receive(:`).with(expected_command).and_return("Error output")
      allow(service).to receive(:process_exit_status).and_return(1)

      service.send(:execute_script)
      job.reload
      expect(job.error).to include("--apiKey [REDACTED]")
      expect(job.error).not_to include("super-secret-key")
    end
  end

  describe "#execute_job_workflow" do
    let(:service) { Sensemaker::JobRunner.new(job) }

    before do
      allow(File).to receive(:exist?).and_return(true)
      allow(service.backend).to receive(:check_runtime_dependencies?).and_return(true)
      allow(service).to receive_messages(check_dependencies?: true, execute_script: "success")
      allow(service).to receive(:prepare_input_data)
    end

    context "when artefacts are complete" do
      it "sets finished_at and does not set error" do
        allow(job.artefacts).to receive(:complete?).and_return(true)

        service.send(:execute_job_workflow)

        job.reload
        expect(job.finished_at).to be_present
        expect(job.error).to be(nil)
      end

      it "sets comments_analysed count when job finishes successfully" do
        allow(job.artefacts).to receive(:complete?).and_return(true)
        allow(service).to receive(:prepare_input_data).and_return(5)

        service.send(:execute_job_workflow)

        job.reload
        expect(job.comments_analysed).to eq(5)
      end
    end

    context "when artefacts are incomplete" do
      it "sets finished_at and error message" do
        allow(job.artefacts).to receive(:complete?).and_return(false)

        service.send(:execute_job_workflow)

        job.reload
        expect(job.finished_at).to be_present
        expect(job.error).to eq("Output file(s) not found")
      end
    end
  end

  describe "#prepare_input_data" do
    let(:service) { Sensemaker::JobRunner.new(job) }
    let(:mock_exporter) { instance_double(Sensemaker::CsvExporter) }
    let(:input_file_path) { "#{Sensemaker::Paths.sensemaker_data_folder}/job-#{job.id}/input.csv" }
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
      allow(service.backend).to receive(:after_input_prepared).and_return(nil)
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
      allow(job).to receive(:conversation).and_return(
        Sensemaker::Conversation.new(job.analysable_type, job.analysable_id)
      )

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
        allow(File).to receive(:exist?).with(job.artefacts.input_path).and_return(true)
        allow(service.backend).to receive(:after_input_prepared).and_call_original
      end

      it "calls CsvExporter.provide_defaults_for_zero_vote_comments via backend" do
        expect(Sensemaker::CsvExporter).to receive(:provide_defaults_for_zero_vote_comments)
          .with(job.artefacts.input_path).and_return(3)
        service.send(:prepare_input_data)
      end

      it "returns the comments count from provide_defaults_for_zero_vote_comments" do
        allow(Sensemaker::CsvExporter).to receive(:provide_defaults_for_zero_vote_comments)
          .with(job.artefacts.input_path).and_return(3)
        result = service.send(:prepare_input_data)

        expect(result).to eq(3)
      end
    end

    context "when script is advanced_runner.ts with blank input_file" do
      before do
        job.script = "advanced_runner.ts"
        job.input_file = nil
        allow(File).to receive(:exist?).with(job.artefacts.input_path).and_return(true)
        allow(service.backend).to receive(:after_input_prepared).and_call_original
      end

      it "calls prepare_with_prep_job and then applies zero-vote defaults" do
        allow(service).to receive(:prepare_with_prep_job).and_return(10)
        allow(Sensemaker::CsvExporter).to receive(:provide_defaults_for_zero_vote_comments)
          .with(job.artefacts.input_path).and_return(10)

        result = service.send(:prepare_input_data)

        expect(result).to eq(10)
        expect(Sensemaker::CsvExporter).to have_received(:provide_defaults_for_zero_vote_comments)
          .with(job.artefacts.input_path)
      end
    end

    context "when script is sensemaking-report-ui with blank input_file" do
      before do
        job.script = "sensemaking-report-ui"
        job.input_file = nil
        allow(mock_conversation).to receive(:target_label).with(format: :full).and_return("Test Report")
        allow(service.backend).to receive(:after_input_prepared).and_call_original
      end

      it "calls prepare_with_prep_job and writes report metadata" do
        allow(service).to receive(:prepare_with_prep_job).and_return(15)
        metadata_path = job.artefacts.metadata_path
        allow(File).to receive(:exist?).with(metadata_path).and_return(false)
        allow(File).to receive(:write)

        result = service.send(:prepare_input_data)

        expect(result).to eq(15)
        expect(File).to have_received(:write).with(metadata_path, anything)
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
