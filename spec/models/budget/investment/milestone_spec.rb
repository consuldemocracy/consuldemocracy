require 'rails_helper'

describe Budget::Investment::Milestone do

  describe "Validations" do
    let(:milestone) { build(:budget_investment_milestone) }

    it "is valid" do
      expect(milestone).to be_valid
    end

    it "is not valid without a title" do
      milestone.title = nil
      expect(milestone).not_to be_valid
    end

    it "is not valid without a description" do
      milestone.description = nil
      expect(milestone).not_to be_valid
    end

    it "is not valid without an investment" do
      milestone.investment_id = nil
      expect(milestone).not_to be_valid
    end
  end

end
