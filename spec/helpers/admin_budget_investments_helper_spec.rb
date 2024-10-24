require "rails_helper"

describe AdminBudgetInvestmentsHelper do
  describe "#admin_select_options" do
    it "includes administrators assigned to the budget" do
      admin = create(:administrator, user: create(:user, username: "Winston"))
      budget = create(:budget, administrators: [admin])

      expect(admin_select_options(budget)).to eq([["Winston", admin.id]])
    end

    it "does not include other administrators" do
      create(:administrator, user: create(:user, username: "Winston"))
      budget = create(:budget, administrators: [])

      expect(admin_select_options(budget)).to be_empty
    end
  end

  describe "#valuator_select_options" do
    it "includes valuators assigned to the budget" do
      valuator = create(:valuator, description: "Kodogo")
      budget = create(:budget, valuators: [valuator])

      expect(valuator_select_options(budget)).to eq([["Kodogo", "valuator_#{valuator.id}"]])
    end

    it "does not include other valuators" do
      create(:valuator, description: "Kodogo")
      budget = create(:budget, valuators: [])

      expect(valuator_select_options(budget)).to be_empty
    end
  end
end
