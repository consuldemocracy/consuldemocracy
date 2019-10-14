require 'rails_helper'

describe Budget::ReclassifiedVote do

  describe "Validations" do
    let(:reclassified_vote) { build(:budget_reclassified_vote) }

    it "should be valid" do
      expect(reclassified_vote).to be_valid
    end

    it "should not be valid without a user" do
      reclassified_vote.user_id = nil
      expect(reclassified_vote).to_not be_valid
    end

    it "should not be valid without an investment" do
      reclassified_vote.investment_id = nil
      expect(reclassified_vote).to_not be_valid
    end

    it "should not be valid without a valid reason" do
      reclassified_vote.reason = nil
      expect(reclassified_vote).to_not be_valid

      reclassified_vote.reason = ""
      expect(reclassified_vote).to_not be_valid

      reclassified_vote.reason = "random"
      expect(reclassified_vote).to_not be_valid

      reclassified_vote.reason = "heading_changed"
      expect(reclassified_vote).to be_valid

      reclassified_vote.reason = "unfeasible"
      expect(reclassified_vote).to be_valid
    end
  end

end