require "rails_helper"

describe Admin::BudgetInvestments::SearchFormComponent do
  describe "#admin_select_options" do
    it "includes administrators assigned to the budget" do
      admin = create(:administrator, user: create(:user, username: "Winston"))
      budget = create(:budget, administrators: [admin])

      render_inline Admin::BudgetInvestments::SearchFormComponent.new(budget)

      expect(page).to have_select options: ["All administrators", "Winston"]
    end

    it "does not include other administrators" do
      create(:administrator, user: create(:user, username: "Winston"))
      budget = create(:budget, administrators: [])

      render_inline Admin::BudgetInvestments::SearchFormComponent.new(budget)

      expect(page).to have_select options: ["All administrators"]
    end
  end

  describe "#valuator_select_options" do
    it "includes valuators assigned to the budget" do
      valuator = create(:valuator, description: "Kodogo")
      budget = create(:budget, valuators: [valuator])

      render_inline Admin::BudgetInvestments::SearchFormComponent.new(budget)

      expect(page).to have_select options: ["All valuators", "Kodogo"]
    end

    it "does not include other valuators" do
      create(:valuator, description: "Kodogo")
      budget = create(:budget, valuators: [])

      render_inline Admin::BudgetInvestments::SearchFormComponent.new(budget)

      expect(page).to have_select options: ["All valuators"]
    end
  end
end
