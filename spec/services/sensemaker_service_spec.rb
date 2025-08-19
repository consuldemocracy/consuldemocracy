require "rails_helper"

describe SensemakerService do
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

  describe "#run" do
    let(:service) { SensemakerService.new(job) }

    before do
      allow(service).to receive(:prepare_input_data)
      allow(service).to receive(:check_dependencies).and_return(true)
      allow(File).to receive(:exist?).and_return(true)
      allow(service).to receive(:system).with("which node > /dev/null 2>&1").and_return(true)
      allow(service).to receive(:system).with("which npx > /dev/null 2>&1").and_return(true)
    end

    it "runs the script and processes the output" do
      expect(service).to receive(:execute_script).and_return(true)
      expect(service).to receive(:process_output)

      service.run

      job.reload
      expect(job.finished_at).to be_present
    end

    it "stops if check_dependencies returns false" do
      allow(service).to receive(:check_dependencies).and_return(false)
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

  describe "#check_dependencies" do
    let(:service) { SensemakerService.new(job) }

    before do
      allow(service).to receive(:system).with("which node > /dev/null 2>&1").and_return(true)
      allow(service).to receive(:system).with("which npx > /dev/null 2>&1").and_return(true)
      allow(File).to receive(:exist?).and_return(true)
    end

    it "returns true when all dependencies are available" do
      result = service.send(:check_dependencies)
      expect(result).to be true
    end

    it "returns false when Node.js is not available" do
      allow(service).to receive(:system).with("which node > /dev/null 2>&1").and_return(false)

      result = service.send(:check_dependencies)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Node.js not found")
    end

    it "returns false when NPX is not available" do
      allow(service).to receive(:system).with("which npx > /dev/null 2>&1").and_return(false)

      result = service.send(:check_dependencies)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("NPX not found")
    end

    it "returns false when the sensemaking folder does not exist" do
      allow(File).to receive(:exist?).with(SensemakerService::SENSEMAKING_FOLDER).and_return(false)

      result = service.send(:check_dependencies)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Sensemaking folder not found")
    end

    it "returns false when the input file does not exist" do
      allow(File).to receive(:exist?).with(SensemakerService::SENSEMAKING_FOLDER).and_return(true)
      allow(File).to receive(:exist?).with(service.input_file).and_return(false)

      result = service.send(:check_dependencies)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Input file not found")
    end

    it "returns false when the key file does not exist" do
      allow(File).to receive(:exist?).with(SensemakerService::SENSEMAKING_FOLDER).and_return(true)
      allow(File).to receive(:exist?).with(service.input_file).and_return(true)
      allow(File).to receive(:exist?).with(service.key_file).and_return(false)

      result = service.send(:check_dependencies)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Key file not found")
    end

    it "returns false when the script file does not exist" do
      allow(File).to receive(:exist?).with(SensemakerService::SENSEMAKING_FOLDER).and_return(true)
      allow(File).to receive(:exist?).with(service.input_file).and_return(true)
      allow(File).to receive(:exist?).with(service.key_file).and_return(true)
      allow(File).to receive(:exist?).with(service.script_file).and_return(false)

      result = service.send(:check_dependencies)

      expect(result).to be false
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to include("Script file not found")
    end
  end

  describe "#execute_script" do
    let(:service) { SensemakerService.new(job) }

    before do
      allow(File).to receive(:exist?).and_return(true)
    end

    it "returns true when the script executes successfully" do
      # Mock the backtick method to simulate successful execution
      expected_command = %r{cd .* && npx ts-node .*categorization_runner\.ts}
      expect(service).to receive(:`).with(expected_command).and_return("Success output")

      allow(service).to receive(:process_exit_status).and_return(0)

      result = service.send(:execute_script)

      expect(result).to be true
    end

    it "returns false and updates the job when the script fails" do
      # Mock the backtick method to simulate failed execution
      expected_command = %r{cd .* && npx ts-node .*categorization_runner\.ts}
      expect(service).to receive(:`).with(expected_command).and_return("Error output")

      allow(service).to receive(:process_exit_status).and_return(1)

      result = service.send(:execute_script)

      expect(result).to be false

      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to eq("Error output")
    end
  end

  describe "#process_output" do
    let(:service) { SensemakerService.new(job) }

    before do
      # Set a default stub for File.exist? to avoid unexpected calls
      allow(File).to receive(:exist?).and_return(true)
    end

    it "creates a SensemakerInfo record when the output file exists" do
      # Mock the File.exist? method to return true for the output file
      allow(File).to receive(:exist?).with(service.output_file).and_return(true)

      result = service.send(:process_output)

      expect(result).to be true

      # Check that a SensemakerInfo record was created
      info = SensemakerInfo.find_by(
        kind: "categorization",
        commentable_type: job.commentable_type,
        commentable_id: job.commentable_id
      )
      expect(info).to be_present
      expect(info.script).to eq(job.script)
      expect(info.generated_at).to eq(job.started_at)
    end

    it "returns false and updates the job when the output file does not exist" do
      # Mock the File.exist? method to return false for the output file
      allow(File).to receive(:exist?).with(service.output_file).and_return(false)

      result = service.send(:process_output)

      expect(result).to be false

      # Check that the job is updated with the error
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to eq("Output file not found")
    end
  end
end
