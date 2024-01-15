require "rails_helper"

describe Valuation::Budgets::RowComponent do
  let(:valuator) { create(:valuator) }

  before { sign_in(valuator.user) }

  describe "investments count" do
    it "counts visible and assigned investments when the budget is in the valuating phase" do
      budget = create(:budget, :valuating)
      create(:budget_investment, :visible_to_valuators, budget: budget, valuators: [valuator])
      create(:budget_investment, :invisible_to_valuators, budget: budget, valuators: [valuator])
      create(:budget_investment, :visible_to_valuators, budget: budget)

      render_inline Valuation::Budgets::RowComponent.new(budget: budget)

      expect(page).to have_selector ".investments-count", text: "1"
    end

    it "counts investments assigned to the valuator group" do
      budget = create(:budget, :valuating)
      valuator_group = create(:valuator_group, valuators: [valuator])
      create(:budget_investment, :visible_to_valuators, budget: budget, valuator_groups: [valuator_group])

      render_inline Valuation::Budgets::RowComponent.new(budget: budget)

      expect(page).to have_selector ".investments-count", text: "1"
    end

    it "does not count investments with valuation finished" do
      budget = create(:budget, :valuating)
      create(:budget_investment, :visible_to_valuators,
                                 budget: budget,
                                 valuators: [valuator],
                                 valuation_finished: true)

      render_inline Valuation::Budgets::RowComponent.new(budget: budget)

      expect(page).to have_selector ".investments-count", text: "0"
    end

    it "displays zero when the budget hasn't reached the valuating phase" do
      budget = create(:budget, :accepting)
      create(:budget_investment, :visible_to_valuators, budget: budget, valuators: [valuator])

      render_inline Valuation::Budgets::RowComponent.new(budget: budget)

      expect(page).to have_selector ".investments-count", text: "0"
    end

    it "displays zero when the valuating phase is over" do
      budget = create(:budget, :finished)
      create(:budget_investment, :visible_to_valuators, budget: budget, valuators: [valuator])

      render_inline Valuation::Budgets::RowComponent.new(budget: budget)

      expect(page).to have_selector ".investments-count", text: "0"
    end
  end

  describe "link to evaluate investments" do
    it "is shown when the valuator has visible investments assigned in the valuating phase" do
      budget = create(:budget, :valuating)
      create(:budget_investment, :visible_to_valuators, budget: budget, valuators: [valuator])

      render_inline Valuation::Budgets::RowComponent.new(budget: budget)

      expect(page).to have_link "Evaluate"
    end

    it "is shown when the investments are assigned to the valuator group" do
      budget = create(:budget, :valuating)
      valuator_group = create(:valuator_group, valuators: [valuator])
      create(:budget_investment, :visible_to_valuators, budget: budget, valuator_groups: [valuator_group])

      render_inline Valuation::Budgets::RowComponent.new(budget: budget)

      expect(page).to have_link "Evaluate"
    end

    it "is shown when the assigned investments have finished valuation" do
      budget = create(:budget, :valuating)
      create(:budget_investment, :visible_to_valuators,
                                 budget: budget,
                                 valuators: [valuator],
                                 valuation_finished: true)

      render_inline Valuation::Budgets::RowComponent.new(budget: budget)

      expect(page).to have_link "Evaluate"
    end

    it "is not shown when the assigned investments aren't visible to valuators" do
      budget = create(:budget, :valuating)
      create(:budget_investment, :invisible_to_valuators, budget: budget, valuators: [valuator])

      render_inline Valuation::Budgets::RowComponent.new(budget: budget)

      expect(page).not_to have_link "Evaluate"
    end

    it "is not shown when the valuator doesn't have assigned investments" do
      budget = create(:budget, :valuating)
      create(:budget_investment, :visible_to_valuators, budget: budget)

      render_inline Valuation::Budgets::RowComponent.new(budget: budget)

      expect(page).not_to have_link "Evaluate"
    end

    it "is not shown when the budget hasn't reached the valuating phase" do
      budget = create(:budget, :accepting)
      create(:budget_investment, :visible_to_valuators, budget: budget, valuators: [valuator])

      render_inline Valuation::Budgets::RowComponent.new(budget: budget)

      expect(page).not_to have_link "Evaluate"
    end

    it "is shown when the valuating phase is over" do
      budget = create(:budget, :finished)
      create(:budget_investment, :visible_to_valuators, budget: budget, valuators: [valuator])

      render_inline Valuation::Budgets::RowComponent.new(budget: budget)

      expect(page).to have_link "Evaluate"
    end
  end
end
