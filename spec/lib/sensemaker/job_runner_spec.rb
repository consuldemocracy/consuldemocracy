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
      allow(File).to receive(:read).with(Sensemaker::Paths.key_file)
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

    it "returns false when the sensemaking-tools package folder does not exist" do
      allow(File).to receive(:exist?).with(Sensemaker::Paths.sensemaker_package_folder).and_return(false)

      result = service.send(:check_dependencies?)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("sensemaking-tools package folder not found")
    end

    it "returns false when the sensemaking data folder does not exist" do
      allow(File).to receive(:exist?).with(Sensemaker::Paths.sensemaker_data_folder).and_return(false)

      result = service.send(:check_dependencies?)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Sensemaker data folder not found")
    end

    it "returns false when the input file does not exist" do
      allow(File).to receive(:exist?).with(Sensemaker::Paths.sensemaker_package_folder).and_return(true)
      allow(File).to receive(:exist?).with(service.input_file).and_return(false)

      result = service.send(:check_dependencies?)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Input file not found")
    end

    it "returns false when the key file does not exist" do
      allow(File).to receive(:exist?).with(Sensemaker::Paths.sensemaker_package_folder).and_return(true)
      allow(File).to receive(:exist?).with(service.input_file).and_return(true)
      allow(File).to receive(:exist?).with(service.key_file).and_return(false)

      result = service.send(:check_dependencies?)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Key file not found")
    end

    it "returns false when the key file is invalid JSON" do
      allow(File).to receive(:exist?).with(Sensemaker::Paths.sensemaker_package_folder).and_return(true)
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
      allow(File).to receive(:exist?).with(Sensemaker::Paths.sensemaker_package_folder).and_return(true)
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
      allow(File).to receive(:exist?).with(Sensemaker::Paths.sensemaker_package_folder).and_return(true)
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
  end

  describe "#build_command" do
    let(:service) { Sensemaker::JobRunner.new(job) }

    before do
      allow(File).to receive(:read).with(Sensemaker::Paths.key_file)
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

    it "returns the correct command for the runner (summary) script" do
      service.job.script = "runner.ts"
      command = service.build_command
      expect(command).to include("npx ts-node #{service.script_file}")
      expect(command).to include("--vertexProject #{service.project_id}")
      expect(command).to include("--modelName #{Tenant.current_secrets.sensemaker_model_name}")
      expect(command).to include("--keyFilename #{service.key_file}")
      expect(command).to include("--inputFile #{service.input_file}")
      expect(command).not_to include("--outputFile")
      expect(command).to include("--outputBasename #{service.output_file}")
    end

    it "returns the correct command for the single-html-build script" do
      service.job.update!(script: "single-html-build.js")
      allow(service.job.conversation).to receive(:target_label).with(format: :full).and_return("Test Label")

      command = service.build_command

      expect(command).to include("npx ts-node site-build.ts")
      expect(command).to include("--topics #{service.input_file}-topic-stats.json")
      expect(command).to include("--summary #{service.input_file}-summary.json")
      expect(command).to include("--comments #{service.input_file}-comments-with-scores.json")
      expect(command).to include('--reportTitle "Report for Test Label"')

      expect(command).to include("npx ts-node single-html-build.js --outputFile #{service.output_file}")
    end
  end

  describe "#input_file" do
    let(:service) { Sensemaker::JobRunner.new(job) }

    it "returns the standard input file for categorization_runner.ts" do
      job.script = "categorization_runner.ts"
      expected_file = "#{Sensemaker::Paths.sensemaker_data_folder}/input-#{job.id}.csv"
      expect(service.input_file).to eq(expected_file)
    end

    it "returns the standard input file for runner.ts" do
      job.script = "runner.ts"
      expected_file = "#{Sensemaker::Paths.sensemaker_data_folder}/input-#{job.id}.csv"
      expect(service.input_file).to eq(expected_file)
    end

    it "returns the standard input file for health_check_runner.ts" do
      job.script = "health_check_runner.ts"
      expected_file = "#{Sensemaker::Paths.sensemaker_data_folder}/input-#{job.id}.csv"
      expect(service.input_file).to eq(expected_file)
    end

    context "when script is advanced_runner.ts" do
      before do
        job.script = "advanced_runner.ts"
      end

      it "returns the categorization output file when job.input_file is not set" do
        job.input_file = nil
        expected_file = "#{Sensemaker::Paths.sensemaker_data_folder}/categorization-output-#{job.id}.csv"
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

  describe "#script_file" do
    let(:service) { Sensemaker::JobRunner.new(job) }

    it "returns the correct path for categorization_runner.ts" do
      job.script = "categorization_runner.ts"
      expected_file = "#{Sensemaker::Paths.sensemaker_package_folder}/runner-cli/categorization_runner.ts"
      expect(service.script_file).to eq(expected_file)
    end

    it "returns the correct path for runner.ts" do
      job.script = "runner.ts"
      expected_file = "#{Sensemaker::Paths.sensemaker_package_folder}/runner-cli/runner.ts"
      expect(service.script_file).to eq(expected_file)
    end

    it "returns the correct path for advanced_runner.ts" do
      job.script = "advanced_runner.ts"
      expected_file = "#{Sensemaker::Paths.sensemaker_package_folder}/runner-cli/advanced_runner.ts"
      expect(service.script_file).to eq(expected_file)
    end

    it "returns the correct path for health_check_runner.ts" do
      job.script = "health_check_runner.ts"
      expected_file = "#{Sensemaker::Paths.sensemaker_package_folder}/runner-cli/health_check_runner.ts"
      expect(service.script_file).to eq(expected_file)
    end

    it "returns the correct path for single-html-build.js" do
      job.script = "single-html-build.js"
      expected_file = "#{Sensemaker::Paths.visualization_folder}/single-html-build.js"
      expect(service.script_file).to eq(expected_file)
    end
  end

  describe "#execute_job_workflow" do
    let(:service) { Sensemaker::JobRunner.new(job) }
    let(:data_folder) { "/tmp/sensemaker_test_folder/data" }

    before do
      allow(Sensemaker::Paths).to receive(:sensemaker_data_folder).and_return(data_folder)
      allow(File).to receive(:exist?).and_return(true)
      allow(service).to receive(:system).with("which node > /dev/null 2>&1").and_return(true)
      allow(service).to receive(:system).with("which npx > /dev/null 2>&1").and_return(true)
      allow(service).to receive_messages(project_id: "sensemaker-466109", check_dependencies?: true,
                                         execute_script: "success")
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

      it "triggers the callback to set persisted_output" do
        job.script = "categorization_runner.ts"
        output_path = "#{data_folder}/categorization-output-#{job.id}.csv"
        allow(File).to receive(:exist?).with(output_path).and_return(true)
        allow(job).to receive(:has_outputs?).and_return(true)

        service.send(:execute_job_workflow)

        job.reload
        expect(job.persisted_output).to eq(job.default_output_path)
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

    context "for advanced_runner.ts" do
      let(:service) { Sensemaker::JobRunner.new(job) }

      before do
        job.update!(script: "advanced_runner.ts")
        allow(service).to receive_messages(check_dependencies?: true, execute_script: "success")
        allow(service).to receive(:prepare_input_data)
      end

      it "checks all output files exist" do
        base_path = "#{data_folder}/output-#{job.id}"
        allow(File).to receive(:exist?).with("#{base_path}-summary.json").and_return(true)
        allow(File).to receive(:exist?).with("#{base_path}-topic-stats.json").and_return(true)
        allow(File).to receive(:exist?).with("#{base_path}-comments-with-scores.json").and_return(true)

        service.send(:execute_job_workflow)

        job.reload
        expect(job.finished_at).to be_present
        expect(job.error).to be(nil)
        expect(job.persisted_output).to eq(job.default_output_path)
      end
    end

    context "for runner.ts" do
      let(:service) { Sensemaker::JobRunner.new(job) }

      before do
        job.update!(script: "runner.ts")
        allow(service).to receive_messages(check_dependencies?: true, execute_script: "success")
        allow(service).to receive(:prepare_input_data)
      end

      it "checks all output files exist" do
        base_path = "#{data_folder}/output-#{job.id}"
        allow(File).to receive(:exist?).with("#{base_path}-summary.json").and_return(true)
        allow(File).to receive(:exist?).with("#{base_path}-summary.html").and_return(true)
        allow(File).to receive(:exist?).with("#{base_path}-summary.md").and_return(true)
        allow(File).to receive(:exist?).with("#{base_path}-summaryAndSource.csv").and_return(true)

        service.send(:execute_job_workflow)

        job.reload
        expect(job.finished_at).to be_present
        expect(job.error).to be(nil)
        expect(job.persisted_output).to eq(job.default_output_path)
      end
    end
  end

  describe "#prepare_input_data" do
    let(:service) { Sensemaker::JobRunner.new(job) }
    let(:mock_exporter) { instance_double(Sensemaker::CsvExporter) }
    let(:input_file_path) { "/path/to/input-file.csv" }
    let(:mock_conversation) { instance_double(Sensemaker::Conversation) }
    let(:mock_comments) { Array.new(7) { double("comment") } }

    before do
      allow(service).to receive(:input_file).and_return(input_file_path)
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

    it "updates the job with additional context" do
      allow(job).to receive(:conversation).and_call_original
      allow(service).to receive(:input_file).and_return(input_file_path)

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
        allow(File).to receive(:exist?).with(input_file_path).and_return(true)
      end

      it "calls CsvExporter.filter_zero_vote_comments_from_csv" do
        expect(Sensemaker::CsvExporter).to receive(:filter_zero_vote_comments_from_csv)
          .with(input_file_path).and_return(3)
        service.send(:prepare_input_data)
      end

      it "returns the filtered count from filter_zero_vote_comments_from_csv" do
        allow(Sensemaker::CsvExporter).to receive(:filter_zero_vote_comments_from_csv)
          .with(input_file_path).and_return(3)
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
        allow(service).to receive(:input_file).and_return(input_file_path)
        allow(File).to receive(:exist?).with(input_file_path).and_return(true)
      end

      it "calls prepare_with_categorization_job and then filters the CSV" do
        allow(service).to receive(:prepare_with_categorization_job).and_return(10)
        allow(Sensemaker::CsvExporter).to receive(:filter_zero_vote_comments_from_csv)
          .with(input_file_path).and_return(8)

        result = service.send(:prepare_input_data)

        expect(result).to eq(8)
        expect(Sensemaker::CsvExporter).to have_received(:filter_zero_vote_comments_from_csv)
          .with(input_file_path)
      end
    end

    context "when script is single-html-build.js with blank input_file" do
      let(:advanced_job) { create(:sensemaker_job, comments_analysed: 15) }

      before do
        job.script = "single-html-build.js"
        job.input_file = nil
      end

      it "calls prepare_with_advanced_runner_job and returns its comments_analysed count" do
        allow(service).to receive(:prepare_with_advanced_runner_job).and_return(15)

        result = service.send(:prepare_input_data)

        expect(result).to eq(15)
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
