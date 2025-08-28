require "rails_helper"

describe Sensemaker::Info do
  let(:debate) { create(:debate) }
  let(:debate_info) do
    create(:sensemaker_info,
           kind: "categorization",
           commentable_type: "Debate",
           commentable_id: debate.id,
           script: "categorization_runner.ts",
           generated_at: Time.current)
  end

  describe "validations" do
    it "is valid with valid attributes" do
      expect(debate_info).to be_valid
    end

    it "requires commentable_type" do
      debate_info.commentable_type = nil
      expect(debate_info).not_to be_valid
    end

    it "requires commentable_id" do
      debate_info.commentable_id = nil
      expect(debate_info).not_to be_valid
    end
  end

  describe ".for" do
    it "finds info by kind, commentable_type, and commentable_id" do
      debate_info
      found_info = Sensemaker::Info.for("categorization", "Debate", debate.id)
      expect(found_info).to eq(debate_info)
    end

    it "returns nil when no matching info is found" do
      found_info = Sensemaker::Info.for("nonexistent", "Debate", debate.id)
      expect(found_info).to be(nil)
    end
  end
end
