require "rails_helper"

describe Admin::BudgetInvestments::ToggleSelectionComponent, :admin do
  context "open budget" do
    let(:budget) { create(:budget) }

    it "is not rendered for not-yet-evaluated investments" do
      unfeasible_investment = create(:budget_investment, :unfeasible, budget: budget)
      feasible_investment = create(:budget_investment, :feasible, budget: budget)

      render_inline Admin::BudgetInvestments::ToggleSelectionComponent.new(unfeasible_investment)
      expect(page).not_to be_rendered

      render_inline Admin::BudgetInvestments::ToggleSelectionComponent.new(feasible_investment)
      expect(page).not_to be_rendered
    end

    it "renders a button to select unselected evaluated investments" do
      valuation_finished_investment = create(:budget_investment, :feasible, :finished, budget: budget)

      render_inline Admin::BudgetInvestments::ToggleSelectionComponent.new(valuation_finished_investment)

      expect(page).to have_button count: 1
      expect(page).to have_button exact_text: "No"
      expect(page).to have_css "button[aria-pressed='false']"
    end

    it "renders a button to deselect selected investments" do
      selected_investment = create(:budget_investment, :selected, budget: budget)

      render_inline Admin::BudgetInvestments::ToggleSelectionComponent.new(selected_investment)

      expect(page).to have_button count: 1
      expect(page).to have_button exact_text: "Yes"
      expect(page).to have_css "button[aria-pressed='true']"
    end
  end

  context "finished budget" do
    let(:budget) { create(:budget, :finished) }

    it "is not rendered for unselected investments" do
      unfeasible_investment = create(:budget_investment, :unfeasible, budget: budget)
      feasible_investment = create(:budget_investment, :feasible, budget: budget)
      valuation_finished_investment = create(:budget_investment, :feasible, :finished, budget: budget)

      render_inline Admin::BudgetInvestments::ToggleSelectionComponent.new(unfeasible_investment)
      expect(page).not_to be_rendered

      render_inline Admin::BudgetInvestments::ToggleSelectionComponent.new(feasible_investment)
      expect(page).not_to be_rendered

      render_inline Admin::BudgetInvestments::ToggleSelectionComponent.new(valuation_finished_investment)
      expect(page).not_to be_rendered
    end

    it "renders plain text for selected investments" do
      selected_investment = create(:budget_investment, :selected, budget: budget)

      render_inline Admin::BudgetInvestments::ToggleSelectionComponent.new(selected_investment)

      expect(page).to have_content "Selected"
      expect(page).not_to have_button
    end
  end
end
