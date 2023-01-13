require "rails_helper"

describe Valuation::Budgets::RowComponent do
  let(:valuator) { create(:valuator) }

  before { sign_in(valuator.user) }

  it "Displays visible and assigned investments count when budget is in valuating phase" do
    budget = create(:budget, :valuating, name: "Sports")
    create(:budget_investment, :visible_to_valuators, budget: budget, valuators: [valuator])
    create(:budget_investment, :invisible_to_valuators, budget: budget, valuators: [valuator])
    create(:budget_investment, :visible_to_valuators, budget: budget)

    render_inline Valuation::Budgets::RowComponent.new(budget: budget)

    expect(page).to have_selector(".investments-count", text: "1")
  end

  it "Displays zero as investments count when budget is not in valuating phase" do
    budget = create(:budget, %i[accepting finished].sample, name: "Sports")
    create(:budget_investment, :visible_to_valuators, budget: budget, valuators: [valuator])

    render_inline Valuation::Budgets::RowComponent.new(budget: budget)

    expect(page).to have_selector(".investments-count", text: "0")
  end
end
