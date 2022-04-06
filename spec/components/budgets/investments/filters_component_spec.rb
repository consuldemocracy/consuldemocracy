require "rails_helper"

describe Budgets::Investments::FiltersComponent do
  let(:budget) { create(:budget) }
  before { allow(controller).to receive(:valid_filters) { budget.investments_filters } }

  around do |example|
    with_request_url(Rails.application.routes.url_helpers.budget_investments_path(budget)) do
      example.run
    end
  end

  it "is not displayed before valuation" do
    %w[informing accepting reviewing selecting].each do |phase|
      budget.update!(phase: phase)

      render_inline Budgets::Investments::FiltersComponent.new

      expect(page).not_to be_rendered
    end
  end

  it "shows the active and unfeasible investments during the valuation phase" do
    budget.update!(phase: "valuating")

    render_inline Budgets::Investments::FiltersComponent.new

    expect(page).to have_link count: 2
    expect(page).to have_link "Active"
    expect(page).to have_link "Unfeasible"
  end

  it "shows the active, unselected and unfeasible filters during the final voting" do
    budget.update!(phase: "balloting")

    render_inline Budgets::Investments::FiltersComponent.new

    expect(page).to have_link count: 3
    expect(page).to have_link "Active"
    expect(page).to have_link "Not selected for the final voting"
    expect(page).to have_link "Unfeasible"
  end

  it "shows the winners, unselected and unfeasible investments when the budget is finished" do
    budget.update!(phase: "finished")

    render_inline Budgets::Investments::FiltersComponent.new

    expect(page).to have_link count: 3
    expect(page).to have_link "Winners"
    expect(page).to have_link "Not selected for the final voting"
    expect(page).to have_link "Unfeasible"
  end
end
