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

  describe "#initialize" do
    it "initializes with the provided job" do
      service = Sensemaker::JobRunner.new(job)
      expect(service.job).to eq(job)
    end
  end

  describe "#run" do
    let(:service) { Sensemaker::JobRunner.new(job) }

    before do
      allow(File).to receive(:exist?).and_return(true)
      allow(service).to receive(:system).with("which node > /dev/null 2>&1").and_return(true)
      allow(service).to receive(:system).with("which npx > /dev/null 2>&1").and_return(true)
      allow(service).to receive_messages(check_dependencies?: true, project_id: "sensemaker-466109")
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
      expect(service).not_to receive(:process_output)

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

    before do
      allow(service).to receive(:system).with("which node > /dev/null 2>&1").and_return(true)
      allow(service).to receive(:system).with("which npx > /dev/null 2>&1").and_return(true)
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:read).with(Sensemaker::JobRunner.key_file)
                                   .and_return('{"project_id": "sensemaker-466109"}')
      allow(File).to receive(:read).with(service.key_file)
                                   .and_return('{"project_id": "sensemaker-466109"}')
    end

    it "returns true when all dependencies are available" do
      result = service.send(:check_dependencies?)
      expect(result).to be true
    end

    it "returns false when sensemaker_data_folder is not configured" do
      allow(Tenant.current_secrets).to receive(:sensemaker_data_folder).and_return(nil)

      result = service.send(:check_dependencies?)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Sensemaker data folder not configured")
    end

    it "returns false when sensemaker_key_file is not configured" do
      allow(Tenant.current_secrets).to receive(:sensemaker_key_file).and_return(nil)

      result = service.send(:check_dependencies?)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Sensemaker key file not configured")
    end

    it "returns false when sensemaker_model_name is not configured" do
      allow(Tenant.current_secrets).to receive(:sensemaker_model_name).and_return(nil)

      result = service.send(:check_dependencies?)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Sensemaker model name not configured")
    end

    it "returns false when Node.js is not available" do
      allow(service).to receive(:system).with("which node > /dev/null 2>&1").and_return(false)

      result = service.send(:check_dependencies?)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Node.js not found")
    end

    it "returns false when NPX is not available" do
      allow(service).to receive(:system).with("which npx > /dev/null 2>&1").and_return(false)

      result = service.send(:check_dependencies?)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("NPX not found")
    end

    it "returns false when the sensemaking-tools folder does not exist" do
      allow(File).to receive(:exist?).with(Sensemaker::JobRunner.sensemaker_folder).and_return(false)

      result = service.send(:check_dependencies?)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("sensemaking-tools folder not found")
    end

    it "returns false when the sensemaking data folder does not exist" do
      allow(File).to receive(:exist?).with(Sensemaker::JobRunner.sensemaker_data_folder).and_return(false)

      result = service.send(:check_dependencies?)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Sensemaker data folder not found")
    end

    it "returns false when the input file does not exist" do
      allow(File).to receive(:exist?).with(Sensemaker::JobRunner.sensemaker_folder).and_return(true)
      allow(File).to receive(:exist?).with(service.input_file).and_return(false)

      result = service.send(:check_dependencies?)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Input file not found")
    end

    it "returns false when the key file does not exist" do
      allow(File).to receive(:exist?).with(Sensemaker::JobRunner.sensemaker_folder).and_return(true)
      allow(File).to receive(:exist?).with(service.input_file).and_return(true)
      allow(File).to receive(:exist?).with(service.key_file).and_return(false)

      result = service.send(:check_dependencies?)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Key file not found")
    end

    it "returns false when the key file is invalid JSON" do
      allow(File).to receive(:exist?).with(Sensemaker::JobRunner.sensemaker_folder).and_return(true)
      allow(File).to receive(:exist?).with(service.input_file).and_return(true)
      allow(File).to receive(:exist?).with(service.key_file).and_return(true)
      allow(File).to receive(:read).with(service.key_file).and_return("invalid json")

      result = service.send(:check_dependencies?)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Key file is invalid")
    end

    it "returns false when the key file is missing project_id" do
      allow(File).to receive(:exist?).with(Sensemaker::JobRunner.sensemaker_folder).and_return(true)
      allow(File).to receive(:exist?).with(service.input_file).and_return(true)
      allow(File).to receive(:exist?).with(service.key_file).and_return(true)
      allow(File).to receive(:read).with(service.key_file).and_return('{"type": "service_account"}')

      result = service.send(:check_dependencies?)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Key file is missing project_id")
    end

    it "returns false when the script file does not exist" do
      allow(File).to receive(:exist?).with(Sensemaker::JobRunner.sensemaker_folder).and_return(true)
      allow(File).to receive(:exist?).with(service.input_file).and_return(true)
      allow(File).to receive(:exist?).with(service.key_file).and_return(true)
      allow(File).to receive(:exist?).with(service.script_file).and_return(false)

      result = service.send(:check_dependencies?)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Script file not found")
    end
  end

  describe "#execute_script" do
    let(:service) { Sensemaker::JobRunner.new(job) }

    before do
      allow(File).to receive(:exist?).and_return(true)
      allow(service).to receive(:project_id).and_return("sensemaker-466109")
    end

    it "returns value when the script executes successfully" do
      # Mock the backtick method to simulate successful execution
      timeout = Sensemaker::JobRunner::TIMEOUT
      expected_command = %r{cd .* && timeout #{timeout} .*}
      expect(service).to receive(:`).with(expected_command).and_return("Success output")

      allow(service).to receive(:process_exit_status).and_return(0)

      result = service.send(:execute_script)

      expect(result).to be_present
    end

    it "returns nil and updates the job when the script fails" do
      # Mock the backtick method to simulate failed execution
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
  end

  describe "#build_command" do
    let(:service) { Sensemaker::JobRunner.new(job) }

    before do
      allow(File).to receive(:read).with(Sensemaker::JobRunner.key_file)
                                   .and_return('{"project_id": "sensemaker-466109"}')
      allow(File).to receive(:read).with(service.key_file)
                                   .and_return('{"project_id": "sensemaker-466109"}')
    end

    it "returns the correct command for the categorization runner" do
      command = service.build_command
      expect(command).to include("npx ts-node #{service.script_file}")
      expect(command).to include("--vertexProject #{service.project_id}")
      expect(command).to include("--modelName #{Tenant.current_secrets.sensemaker_model_name}")
      expect(command).to include("--keyFilename #{service.key_file}")
      expect(command).to include("--inputFile #{service.input_file}")
      expect(command).to include("--outputFile #{service.output_file}")
    end

    it "returns the correct command for the advanced runner" do
      service.job.script = "advanced_runner.ts"
      command = service.build_command
      expect(command).to include("npx ts-node #{service.script_file}")
      expect(command).to include("--vertexProject #{service.project_id}")
      expect(command).to include("--modelName #{Tenant.current_secrets.sensemaker_model_name}")
      expect(command).to include("--keyFilename #{service.key_file}")
      expect(command).to include("--inputFile #{service.input_file}")
      expect(command).not_to include("--outputFile")
      expect(command).to include("--outputBasename #{service.output_file}")
    end
  end

  describe "#input_file" do
    let(:service) { Sensemaker::JobRunner.new(job) }

    it "returns the standard input file for categorization_runner.ts" do
      job.script = "categorization_runner.ts"
      expected_file = "#{Sensemaker::JobRunner.sensemaker_data_folder}/input-#{job.id}.csv"
      expect(service.input_file).to eq(expected_file)
    end

    it "returns the standard input file for runner.ts" do
      job.script = "runner.ts"
      expected_file = "#{Sensemaker::JobRunner.sensemaker_data_folder}/input-#{job.id}.csv"
      expect(service.input_file).to eq(expected_file)
    end

    it "returns the standard input file for health_check_runner.ts" do
      job.script = "health_check_runner.ts"
      expected_file = "#{Sensemaker::JobRunner.sensemaker_data_folder}/input-#{job.id}.csv"
      expect(service.input_file).to eq(expected_file)
    end

    context "when script is advanced_runner.ts" do
      before do
        job.script = "advanced_runner.ts"
      end

      it "returns the categorization output file when job.input_file is not set" do
        job.input_file = nil
        expected_file = "#{Sensemaker::JobRunner.sensemaker_data_folder}/categorization-output-#{job.id}.csv"
        expect(service.input_file).to eq(expected_file)
      end

      it "returns the job.input_file when it is set" do
        custom_file = "/custom/path/to/input.csv"
        job.input_file = custom_file
        expect(service.input_file).to eq(custom_file)
      end

      it "returns the default path when it is an empty string" do
        job.input_file = ""
        expect(service.input_file).not_to eq("")
      end
    end
  end

  describe "#output_file_name" do
    let(:service) { Sensemaker::JobRunner.new(job) }
    it "returns the correct output file name" do
      expect(service.send(:output_file_name)).to eq("categorization-output-#{job.id}.csv")
      job.script = "advanced_runner.ts"
      expect(service.send(:output_file_name)).to eq("output-#{job.id}")
      job.script = "runner.ts"
      expect(service.send(:output_file_name)).to eq("output-#{job.id}.csv")
      job.script = "health_check_runner.ts"
      expect(service.send(:output_file_name)).to eq("health-check-#{job.id}.txt")
    end
  end

  describe "#process_output" do
    let(:service) { Sensemaker::JobRunner.new(job) }

    before do
      allow(File).to receive(:exist?).and_return(true)
    end

    it "returns true and sets persisted_output when the output file exists" do
      allow(File).to receive(:exist?).with(service.output_file).and_return(true)

      result = service.send(:process_output)

      expect(result).to be true

      job.reload
      expect(job.persisted_output).to eq(service.output_file)
    end

    it "sets persisted_output to the copied report file for single-html-build.js script" do
      job.update!(script: "single-html-build.js")
      service = Sensemaker::JobRunner.new(job)

      allow(File).to receive(:exist?).with(service.output_file).and_return(true)
      allow(FileUtils).to receive(:cp)

      result = service.send(:process_output)

      expect(result).to be true

      job.reload
      expected_path = "#{Sensemaker::JobRunner.sensemaker_data_folder}/report-#{job.id}.html"
      expect(job.persisted_output).to eq(expected_path)
    end

    it "returns nil and updates the job when the output file does not exist" do
      allow(File).to receive(:exist?).with(service.output_file).and_return(false)

      result = service.send(:process_output)

      expect(result).to be nil

      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to eq("Output file not found")
    end
  end

  describe "#prepare_input_data" do
    let(:service) { Sensemaker::JobRunner.new(job) }
    let(:mock_exporter) { instance_double(Sensemaker::CsvExporter) }
    let(:input_file_path) { "/path/to/input-file.csv" }

    before do
      allow(service).to receive(:input_file).and_return(input_file_path)
      allow(Sensemaker::CsvExporter).to receive(:new).and_return(mock_exporter)
      allow(mock_exporter).to receive(:export_to_csv)
    end

    it "creates a CsvExporter with the job's conversation" do
      service.send(:prepare_input_data)

      expect(Sensemaker::CsvExporter).to have_received(:new).with(job.conversation)
    end

    it "exports CSV data to the input file" do
      service.send(:prepare_input_data)

      expect(mock_exporter).to have_received(:export_to_csv).with(input_file_path)
    end

    it "updates the job with additional context" do
      service.send(:prepare_input_data)

      job.reload
      expect(job.additional_context).to be_present
      expect(job.additional_context).to include("Analyzing citizen Debate")
      expect(job.additional_context).to include(debate.title)
    end

    context "when script is advanced_runner.ts" do
      before do
        job.script = "advanced_runner.ts"
        job.input_file = "/tmp/categorization-output.csv"
      end

      it "calls CsvExporter.filter_zero_vote_comments_from_csv" do
        expect(Sensemaker::CsvExporter).to receive(:filter_zero_vote_comments_from_csv).with(input_file_path)
        service.send(:prepare_input_data)
      end
    end
  end
end
