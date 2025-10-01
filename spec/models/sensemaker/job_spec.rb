require "rails_helper"

describe Sensemaker::Job do
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

  describe "validations" do
    it "is valid with valid attributes" do
      expect(job).to be_valid
    end

    it "requires commentable_type" do
      job.commentable_type = nil
      expect(job).not_to be_valid
    end

    it "requires commentable_id" do
      job.commentable_id = nil
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

    describe "#errored?" do
      it "returns true when error is present" do
        job.error = "Some error occurred"
        expect(job.errored?).to be true
      end

      it "returns false when error is nil" do
        expect(job.errored?).to be false
      end
    end

    describe "#has_output?" do
      it "returns true when persisted_output is present and file exists" do
        job.persisted_output = "/path/to/existing/file.txt"
        allow(File).to receive(:exist?).with("/path/to/existing/file.txt").and_return(true)
        expect(job.has_output?).to be true
      end

      it "returns false when persisted_output is nil" do
        job.persisted_output = nil
        expect(job.has_output?).to be false
      end

      it "returns false when persisted_output is present but file does not exist" do
        job.persisted_output = "/path/to/nonexistent/file.txt"
        allow(File).to receive(:exist?).with("/path/to/nonexistent/file.txt").and_return(false)
        expect(job.has_output?).to be false
      end
    end
  end
end
