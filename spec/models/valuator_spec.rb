require "rails_helper"

describe Valuator do

  describe "#description_or_email" do
    it "returns description if present" do
      valuator = create(:valuator, description: "Urbanism manager")

      expect(valuator.description_or_email).to eq("Urbanism manager")
    end

    it "returns email if not description present" do
      valuator = create(:valuator)

      expect(valuator.description_or_email).to eq(valuator.email)
    end
  end

  describe "#assigned_investment_ids" do

    it "returns investments assigned to a valuator" do
      valuator = create(:valuator)
      investment1 = create(:budget_investment)
      investment2 = create(:budget_investment)
      investment3 = create(:budget_investment)

      investment1.valuators << valuator
      investment2.valuators << valuator

      assigned_investment_ids = valuator.assigned_investment_ids
      expect(assigned_investment_ids).to include investment1.id
      expect(assigned_investment_ids).to include investment2.id
      expect(assigned_investment_ids).not_to include investment3.id
    end

    it "returns investments assigned to a valuator group" do
      group = create(:valuator_group)
      valuator = create(:valuator, valuator_group: group)

      investment1 = create(:budget_investment)
      investment2 = create(:budget_investment)
      investment3 = create(:budget_investment)

      investment1.valuator_groups << group
      investment2.valuator_groups << group

      assigned_investment_ids = valuator.assigned_investment_ids
      expect(assigned_investment_ids).to include investment1.id
      expect(assigned_investment_ids).to include investment2.id
      expect(assigned_investment_ids).not_to include investment3.id
    end
  end
end
