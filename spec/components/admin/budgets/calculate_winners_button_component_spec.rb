require "rails_helper"

describe Admin::Budgets::CalculateWinnersButtonComponent, controller: Admin::BaseController do
  let(:budget) { create(:budget) }
  let(:component) { Admin::Budgets::CalculateWinnersButtonComponent.new(budget) }
  before { sign_in(create(:administrator).user) }

  it "renders when reviewing ballots" do
    budget.update!(phase: "reviewing_ballots")

    render_inline component

    expect(page).to have_button "Calculate Winner Investments"
    expect(page).not_to have_button "Recalculate Winner Investments"
  end

  it "does not render before balloting has finished" do
    budget.update!(phase: "balloting")

    render_inline component

    expect(page).not_to have_button "Calculate Winner Investments"
    expect(page).not_to have_button "Recalculate Winner Investments"
  end

  it "does not render after the budget process has finished" do
    budget.update!(phase: "finished")

    render_inline component

    expect(page).not_to have_button "Calculate Winner Investments"
    expect(page).not_to have_button "Recalculate Winner Investments"
  end

  context "budget with winners" do
    before { create(:budget_investment, :winner, budget: budget) }

    it "renders when reviewing ballots" do
      budget.update!(phase: "reviewing_ballots")

      render_inline component

      expect(page).to have_button "Recalculate Winner Investments"
      expect(page).not_to have_button "Calculate Winner Investments"
    end

    it "does not render before balloting has finished" do
      budget.update!(phase: "balloting")

      render_inline component

      expect(page).not_to have_button "Calculate Winner Investments"
      expect(page).not_to have_button "Recalculate Winner Investments"
    end

    it "does not render after the budget process has finished" do
      budget.update!(phase: "finished")

      render_inline component

      expect(page).not_to have_button "Calculate Winner Investments"
      expect(page).not_to have_button "Recalculate Winner Investments"
    end
  end
end
