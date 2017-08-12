require 'rails_helper'

describe "Budget::Investment::Milestone" do

  describe "Validations" do
    let(:milestone) { build(:budget_investment_milestone) }

    it "Should be valid" do
      expect(milestone).to be_valid
    end

    it "Should not be valid without a title" do
      milestone.title = nil
      expect(milestone).to_not be_valid
    end

    it "Should not be valid without an investment" do
      milestone.investment_id = nil
      expect(milestone).to_not be_valid
    end
  end

end
