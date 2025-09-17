require "rails_helper"

describe Sensemaker::JobRunner do
  let(:user) { create(:user) }
  let(:debate) { create(:debate) }
  let(:job) do
    create(:sensemaker_job,
           commentable_type: "Debate",
           commentable_id: debate.id,
           script: "categorization_runner.ts",
           user: user,
           started_at: Time.current,
           additional_context: "")
  end

  describe "#run" do
    let(:service) { Sensemaker::JobRunner.new(job) }

    before do
      allow(File).to receive(:exist?).and_return(true)
      allow(service).to receive(:system).with("which node > /dev/null 2>&1").and_return(true)
      allow(service).to receive(:system).with("which npx > /dev/null 2>&1").and_return(true)
      allow(service).to receive_messages(check_dependencies?: true, project_id: "sensemaker-466109")
    end

    it "runs the script and processes the output" do
      allow(service).to receive(:prepare_input_data)

      expect(service).to receive(:execute_script).and_return(true)
      expect(service).to receive(:process_output)

      service.run

      job.reload
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
      expected_command = %r{cd .* && npx ts-node .*categorization_runner\.ts}
      expect(service).to receive(:`).with(expected_command).and_return("Success output")

      allow(service).to receive(:process_exit_status).and_return(0)

      result = service.send(:execute_script)

      expect(result).to be_present
    end

    it "returns nil and updates the job when the script fails" do
      # Mock the backtick method to simulate failed execution
      expected_command = %r{cd .* && npx ts-node .*categorization_runner\.ts}
      expect(service).to receive(:`).with(expected_command).and_return("Error output")

      allow(service).to receive(:process_exit_status).and_return(1)

      result = service.send(:execute_script)

      expect(result).to be nil

      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to eq("Error output")
    end
  end

  describe "#build_command" do
    let(:service) { Sensemaker::JobRunner.new(job) }
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

  describe "#output_file_name" do
    let(:service) { Sensemaker::JobRunner.new(job) }
    it "returns the correct output file name" do
      expect(service.send(:output_file_name)).to eq("output-#{job.id}.csv")
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
      # Set a default stub for File.exist? to avoid unexpected calls
      allow(File).to receive(:exist?).and_return(true)
    end

    it "creates a Sensemaker::Info record when the output file exists" do
      # Mock the File.exist? method to return true for the output file
      allow(File).to receive(:exist?).with(service.output_file).and_return(true)

      result = service.send(:process_output)

      expect(result).to be_present

      # Check that a Sensemaker::Info record was created
      info = Sensemaker::Info.find_by(
        kind: "categorization",
        commentable_type: job.commentable_type,
        commentable_id: job.commentable_id
      )
      expect(info).to be_present
      expect(info.script).to eq(job.script)
      expect(info.generated_at).to eq(job.started_at)
    end

    it "returns nil and updates the job when the output file does not exist" do
      # Mock the File.exist? method to return false for the output file
      allow(File).to receive(:exist?).with(service.output_file).and_return(false)

      result = service.send(:process_output)

      expect(result).to be nil

      # Check that the job is updated with the error
      job.reload
      expect(job.finished_at).to be_present
      expect(job.error).to eq("Output file not found")
    end
  end

  describe ".compile_context" do
    let(:service) { Sensemaker::JobRunner.new(job) }

    it "can compile context for Poll" do
      answer_one = create(:poll_answer)
      answer_two = create(:poll_answer)
      poll = answer_one.poll

      expect(answer_one.persisted?).to be true
      expect(answer_two.persisted?).to be true
      expect(poll.persisted?).to be true

      context_result = service.class.compile_context(poll)

      expect(context_result).to be_present
      expect(context_result).to include("Questions and Responses:")
      expect(context_result).to include("Q: #{poll.questions.first.title}:")
      expect(context_result).to include(" - #{answer_one.option.title}")
      expect(context_result).to include(" - #{answer_two.option.title}")
    end

    it "can compile context for Proposal" do
      proposal = create(:proposal)
      expect(proposal.persisted?).to be true

      context_result = service.class.compile_context(proposal)
      expect(context_result).to be_present
      expect(context_result).to include(
        "This proposal has #{proposal.total_votes} votes out of #{Proposal.votes_needed_for_success} required"
      )
    end

    it "can compile context for Debate" do
      debate = create(:debate)
      expect(debate.persisted?).to be true

      context_result = service.class.compile_context(debate)
      expect(context_result).to be_present
      expect(context_result).to include(
        "This debate has #{debate.cached_votes_up} votes for and #{debate.cached_votes_down} votes against"
      )
    end

    it "can compile context for Legislation::Proposal" do
      proposal = create(:legislation_proposal)
      expect(proposal.persisted?).to be true

      context_result = service.class.compile_context(proposal)
      expect(context_result).to be_present
      expect(context_result).to include(
        "This proposal is part of the legislation process, \"#{proposal.process.title}\""
      )
    end

    it "can compile context for Legislation::Question without question options" do
      question = create(:legislation_question)
      expect(question.persisted?).to be true

      context_result = service.class.compile_context(question)
      expect(context_result).to be_present
      expect(context_result).to include(
        "This question is part of the legislation process, \"#{question.process.title}\""
      )
      expect(context_result).not_to include("Question Responses:")
    end

    it "can compile context for Legislation::Question with question options" do
      question = create(:legislation_question)
      2.times do
        create(:legislation_question_option, question: question)
      end
      3.times do
        create(:legislation_answer, question: question, question_option: question.question_options.sample)
      end
      expect(question.persisted?).to be true

      context_result = service.class.compile_context(question)
      expect(context_result).to be_present
      expect(context_result).to include("Question Responses:")
      expect(context_result).to include(" - #{question.question_options.first.value}")
      expect(context_result).to include(" - #{question.question_options.last.value}")
    end

    it "can compile context for other target types" do
      target_types = Sensemaker::Job::TARGET_TYPES - ["Poll", "Legislation::Question",
                                                      "Legislation::Proposal", "Debate"]
      target_types.each do |target_type|
        target_factory = target_type.downcase.gsub("::", "_").to_sym
        target = create(target_factory)
        expect(target.persisted?).to be true
        3.times do
          create(:comment, commentable: target, user: user)
        end
        context_result = service.class.compile_context(target)
        expect(context_result).to be_present, "Failed to compile context for #{target_factory}"
        expect(context_result).to include("Comments: #{target.comments_count}")
      end
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

    it "creates a CsvExporter with the job's target" do
      service.send(:prepare_input_data)

      expect(Sensemaker::CsvExporter).to have_received(:new).with(job.commentable)
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
  end
end
