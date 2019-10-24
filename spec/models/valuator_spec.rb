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
      investment1 = create(:budget_investment, valuators: [valuator])
      investment2 = create(:budget_investment, valuators: [valuator])
      investment3 = create(:budget_investment)

      assigned_investment_ids = valuator.assigned_investment_ids

      expect(assigned_investment_ids).to match_array [investment1.id, investment2.id]
      expect(assigned_investment_ids).not_to include investment3.id
    end

    it "returns investments assigned to a valuator group" do
      group = create(:valuator_group)
      valuator = create(:valuator, valuator_group: group)

      investment1 = create(:budget_investment, valuator_groups: [group])
      investment2 = create(:budget_investment, valuator_groups: [group])
      investment3 = create(:budget_investment)

      assigned_investment_ids = valuator.assigned_investment_ids

      expect(assigned_investment_ids).to match_array [investment1.id, investment2.id]
      expect(assigned_investment_ids).not_to include investment3.id
    end
  end

  describe "abilities" do
    context "by default" do
      let(:valuator) { Valuator.new }
      it { expect(valuator.can_comment).to be_truthy }
      it { expect(valuator.can_edit_dossier).to be_truthy }
    end
  end
end
