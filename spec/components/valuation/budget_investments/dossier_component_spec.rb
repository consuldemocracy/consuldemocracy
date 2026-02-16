require "rails_helper"

describe Valuation::BudgetInvestments::DossierComponent do
  it "uses the same currency as the investment's budget" do
    dollar_investment = create(:budget_investment, budget: create(:budget, currency_symbol: "$"))
    euro_investment = create(:budget_investment, budget: create(:budget, currency_symbol: "€"))

    render_inline Valuation::BudgetInvestments::DossierComponent.new(dollar_investment)

    expect(page).to have_content "Price ($)"
    expect(page).to have_content "Cost during the first year ($)"

    render_inline Valuation::BudgetInvestments::DossierComponent.new(euro_investment)

    expect(page).to have_content "Price (€)"
    expect(page).to have_content "Cost during the first year (€)"
  end
end
