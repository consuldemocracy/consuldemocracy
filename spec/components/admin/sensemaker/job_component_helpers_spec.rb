require "rails_helper"

describe Admin::Sensemaker::JobComponentHelpers do
  let(:test_class) do
    Class.new do
      include Admin::Sensemaker::JobComponentHelpers

      attr_reader :job

      def initialize(job)
        @job = job
      end
    end
  end

  let(:user) { create(:user) }
  let(:debate) { create(:debate) }
  let(:sensemaker_job) do
    create(:sensemaker_job, user: user, analysable_type: "Debate", analysable_id: debate.id)
  end
  let(:component) { test_class.new(sensemaker_job) }

  describe "#job_status_class" do
    it "returns the correct CSS class for running status" do
      expect(component.job_status_class).to eq("job-status-running")
    end

    context "when job is completed" do
      before do
        sensemaker_job.update!(finished_at: Time.current)
      end

      it "returns completed status class" do
        expect(component.job_status_class).to eq("job-status-completed")
      end
    end

    context "when job is failed" do
      before do
        sensemaker_job.update!(finished_at: Time.current, error: "Test error")
      end

      it "returns failed status class" do
        expect(component.job_status_class).to eq("job-status-failed")
      end
    end
  end

  describe "#analysable_title" do
    it "returns the analysable title" do
      expect(component.analysable_title).to eq(debate.title)
    end

    context "when analysable is deleted" do
      before do
        allow(sensemaker_job).to receive(:analysable).and_return(nil)
      end

      it "returns deleted message" do
        expect(component.analysable_title).to eq("(deleted)")
      end
    end
  end

  describe "#has_error?" do
    context "when job has no error" do
      it "returns false" do
        expect(component.has_error?).to be false
      end
    end

    context "when job has error but status is not Failed" do
      before do
        sensemaker_job.update!(started_at: Time.current, finished_at: nil, error: nil)
      end

      it "returns false" do
        expect(sensemaker_job.status).to eq("Running")
        expect(component.has_error?).to be false
      end
    end

    context "when job has error and status is Failed" do
      before do
        sensemaker_job.update!(error: "Test error", finished_at: Time.current)
      end

      it "returns true" do
        expect(component.has_error?).to be true
      end
    end
  end

  describe "#can_download?" do
    context "when job is not finished" do
      it "returns false" do
        expect(component.can_download?).to be false
      end
    end

    context "when job is finished but has no output" do
      before do
        sensemaker_job.update!(finished_at: Time.current, persisted_output: nil)
      end

      it "returns true (can download even without persisted_output if no error)" do
        expect(component.can_download?).to be true
      end
    end

    context "when job is finished and has output" do
      before do
        sensemaker_job.update!(
          finished_at: Time.current,
          persisted_output: "/path/to/output.html"
        )
      end

      it "returns true" do
        expect(component.can_download?).to be true
      end
    end

    context "when job is finished but has error" do
      before do
        sensemaker_job.update!(
          finished_at: Time.current,
          error: "Test error",
          persisted_output: "/path/to/output.html"
        )
      end

      it "returns false" do
        expect(component.can_download?).to be false
      end
    end
  end

  describe "#parent_job?" do
    context "when job has no parent" do
      it "returns true" do
        expect(component.parent_job?).to be true
      end
    end

    context "when job has a parent" do
      let(:parent_job) { create(:sensemaker_job) }
      let(:sensemaker_job) { create(:sensemaker_job, parent_job: parent_job) }

      it "returns false" do
        expect(component.parent_job?).to be false
      end
    end
  end
end
