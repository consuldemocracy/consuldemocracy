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

    it "is not valid without a description if status is empty" do
      milestone.status = nil
      milestone.description = nil
      expect(milestone).not_to be_valid
    end

    it "is valid without a description if status is present" do
      milestone.description = nil
      expect(milestone).to be_valid
    end

    it "is not valid without an investment" do
      milestone.investment_id = nil
      expect(milestone).not_to be_valid
    end

    it "is not valid if description and status are not present" do
      milestone.description = nil
      milestone.status_id = nil
      expect(milestone).not_to be_valid
    end

    it "is valid without status if description is present" do
      milestone.status_id = nil
      expect(milestone).to be_valid
    end

    it "is valid without description if status is present" do
      milestone.description = nil
      expect(milestone).to be_valid
    end
  end

  describe "#description_or_status_present?" do
    let(:milestone) { build(:budget_investment_milestone) }

    it "is not valid when status is removed and there's no description" do
      milestone.update(description: nil)
      expect(milestone.update(status_id: nil)).to be false
    end

    it "is not valid when description is removed and there's no status" do
      milestone.update(status_id: nil)
      expect(milestone.update(description: nil)).to be false
    end

    it "is valid when description is removed and there is a status" do
      expect(milestone.update(description: nil)).to be true
    end

    it "is valid when status is removed and there is a description" do
      expect(milestone.update(status_id: nil)).to be true
    end
  end

end
