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

    describe "#publishing_is_allowed" do
      let(:data_folder) { "/tmp/sensemaker_test_folder/data" }

      before do
        allow(Sensemaker::Paths).to receive(:sensemaker_data_folder).and_return(data_folder)
        allow(File).to receive(:exist?).and_return(false)
        job.published = false
      end

      context "when job is publishable" do
        before do
          job.script = "sensemaking-report-ui"
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

  describe ".for_analysable" do
    context "when record is a Budget" do
      let(:budget) { create(:budget) }
      let!(:published_budget_job) do
        j = create(:sensemaker_job, analysable_type: "Budget", analysable_id: budget.id, published: false)
        j.update_column(:published, true)
        j
      end
      let!(:unpublished_budget_job) do
        create(:sensemaker_job, analysable_type: "Budget", analysable_id: budget.id, published: false)
      end
      let!(:other_budget_job) do
        j = create(:sensemaker_job,
                   analysable_type: "Budget",
                   analysable_id: create(:budget).id,
                   published: false)
        j.update_column(:published, true)
        j
      end

      it "with published_only: true returns only published jobs for that budget" do
        scope = Sensemaker::Job.for_analysable(budget, published_only: true)
        expect(scope).to include(published_budget_job)
        expect(scope).not_to include(unpublished_budget_job)
        expect(scope).not_to include(other_budget_job)
      end

      it "with published_only: false returns all jobs for that budget" do
        scope = Sensemaker::Job.for_analysable(budget, published_only: false)
        expect(scope).to include(published_budget_job)
        expect(scope).to include(unpublished_budget_job)
        expect(scope).not_to include(other_budget_job)
      end
    end

    context "when record is a Debate (else branch)" do
      let(:debate) { create(:debate) }
      let!(:published_debate_job) do
        j = create(:sensemaker_job, analysable_type: "Debate", analysable_id: debate.id, published: false)
        j.update_column(:published, true)
        j
      end
      let!(:unpublished_debate_job) do
        create(:sensemaker_job, analysable_type: "Debate", analysable_id: debate.id, published: false)
      end

      it "with published_only: true returns only published jobs for that record" do
        scope = Sensemaker::Job.for_analysable(debate, published_only: true)
        expect(scope).to include(published_debate_job)
        expect(scope).not_to include(unpublished_debate_job)
      end

      it "with published_only: false returns all jobs for that record" do
        scope = Sensemaker::Job.for_analysable(debate, published_only: false)
        expect(scope).to include(published_debate_job)
        expect(scope).to include(unpublished_debate_job)
      end
    end

    context "when record is Proposal (all proposals)" do
      let!(:all_proposals_job) do
        j = create(:sensemaker_job, analysable_type: "Proposal", analysable_id: nil, published: false)
        j.update_column(:published, true)
        j
      end
      let!(:specific_proposal_job) do
        j = create(:sensemaker_job,
                   analysable_type: "Proposal",
                   analysable_id: create(:proposal).id,
                   published: false)
        j.update_column(:published, true)
        j
      end

      it "with published_only: true returns only published jobs with nil analysable_id" do
        scope = Sensemaker::Job.for_analysable(Proposal, published_only: true)
        expect(scope).to include(all_proposals_job)
        expect(scope).not_to include(specific_proposal_job)
      end

      it "with published_only: false returns all jobs with nil analysable_id" do
        unpublished = create(:sensemaker_job,
                             analysable_type: "Proposal",
                             analysable_id: nil,
                             published: false)
        scope = Sensemaker::Job.for_analysable(Proposal, published_only: false)
        expect(scope).to include(all_proposals_job)
        expect(scope).to include(unpublished)
        expect(scope).not_to include(specific_proposal_job)
      end
    end

    context "when record is a Poll" do
      let(:poll) { create(:poll) }
      let!(:published_poll_job) do
        j = create(:sensemaker_job, analysable_type: "Poll", analysable_id: poll.id, published: false)
        j.update_column(:published, true)
        j
      end
      let!(:unpublished_poll_job) do
        create(:sensemaker_job, analysable_type: "Poll", analysable_id: poll.id, published: false)
      end

      it "with published_only: false returns all jobs for that poll" do
        scope = Sensemaker::Job.for_analysable(poll, published_only: false)
        expect(scope).to include(published_poll_job)
        expect(scope).to include(unpublished_poll_job)
      end
    end
  end

  describe "instance methods" do
    describe "#artefacts" do
      it "returns a JobArtefacts instance for the job" do
        expect(job.artefacts).to be_a(Sensemaker::JobArtefacts)
        expect(job.artefacts.job).to eq(job)
      end

      it "memoizes the artefacts instance" do
        expect(job.artefacts).to equal(job.artefacts)
      end
    end

    describe "#conversation" do
      it "returns a Sensemaker::Conversation for the job analysable" do
        expect(job.conversation).to be_a(Sensemaker::Conversation)
        expect(job.conversation.target).to eq(debate)
      end

      it "memoizes the conversation instance" do
        expect(job.conversation).to equal(job.conversation)
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

    describe "#publishable?" do
      include_context "sensemaker paths stubbed"

      before do
        allow(File).to receive(:exist?).and_return(false)
        job.script = "sensemaking-report-ui"
        job.finished_at = Time.current
        job.error = nil
      end

      it "returns true for a finished successful job with complete outputs" do
        output_path = "#{data_folder}/report-#{job.id}.html"
        allow(File).to receive(:exist?).with(output_path).and_return(true)

        expect(job.publishable?).to be true
      end

      it "returns false when the script is not publishable" do
        job.script = "categorization_runner.ts"

        expect(job.publishable?).to be false
      end

      it "returns false when the job is not finished" do
        job.finished_at = nil

        expect(job.publishable?).to be false
      end

      it "returns false when the job has an error" do
        job.error = "Something went wrong"

        expect(job.publishable?).to be false
      end

      it "returns false when output artefacts are incomplete" do
        expect(job.publishable?).to be false
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
        it "sets persisted_output to relative_output_path for #{script_name}" do
          job.script = script_name
          paths = paths_fn.call(job, data_folder)
          paths.each { |p| allow(File).to receive(:exist?).with(p).and_return(true) }

          job.finished_at = Time.current
          job.error = nil
          job.save!

          expect(job.persisted_output).to eq(job.artefacts.relative_output_path)
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
            existing_path = "vendor/sensemaking-tools/data/output-#{job.id}"
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

      it "calls artefacts.cleanup when job is destroyed" do
        expect(job.artefacts).to receive(:cleanup).and_return([])
        job.destroy!
      end

      it "logs cleanup results" do
        allow(job.artefacts).to receive(:cleanup).and_return(["/tmp/cleaned"])
        expect(Rails.logger).to receive(:info).with(/Cleaned up files for job #{job.id}/)

        job.destroy!
      end

      it "continues with destruction even if cleanup fails" do
        allow(job.artefacts).to receive(:cleanup).and_return(nil)
        expect(Rails.logger).to receive(:warn).with(/Failed to cleanup files for job #{job.id}/)

        expect { job.destroy }.not_to raise_error
        expect(Sensemaker::Job.find_by(id: job.id)).to be(nil)
      end
    end
  end
end
