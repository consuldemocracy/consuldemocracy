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
  end

  describe "associations" do
    it "belongs to a user" do
      expect(job.user).to eq(user)
    end
  end

  describe "instance methods" do
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
  end
end
