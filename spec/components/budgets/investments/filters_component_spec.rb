require "rails_helper"

describe Budgets::Investments::FiltersComponent do
  let(:budget) { create(:budget) }

  around do |example|
    with_request_url(Rails.application.routes.url_helpers.budget_investments_path(budget)) do
      example.run
    end
  end

  it "is not displayed before valuation" do
    %w[informing accepting reviewing selecting].each do |phase|
      budget.update!(phase: phase)
      allow(controller).to receive(:valid_filters).and_return(budget.investments_filters)

      render_inline Budgets::Investments::FiltersComponent.new

      expect(page).not_to be_rendered
    end
  end

  it "is displayed during and after valuation" do
    Budget::Phase::kind_or_later("valuating").each do |phase|
      budget.update!(phase: phase)
      allow(controller).to receive(:valid_filters).and_return(budget.investments_filters)

      render_inline Budgets::Investments::FiltersComponent.new

      expect(page).to have_content "Filtering projects by"
    end
  end
end
