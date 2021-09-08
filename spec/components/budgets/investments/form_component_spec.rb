require "rails_helper"

describe Budgets::Investments::FormComponent do
  include Rails.application.routes.url_helpers

  let(:budget) { create(:budget) }
  before { sign_in(create(:user)) }

  around do |example|
    with_request_url(new_budget_investment_path(budget)) { example.run }
  end

  describe "accept terms of services field" do
    it "is shown for new investments" do
      investment = build(:budget_investment, budget: budget)

      render_inline Budgets::Investments::FormComponent.new(
        investment,
        url: budget_investments_path(budget)
      )

      expect(page).to have_field "I agree to the Privacy Policy and the Terms and conditions of use"
    end

    it "is not shown for existing investments" do
      investment = create(:budget_investment, budget: budget)

      render_inline Budgets::Investments::FormComponent.new(
        investment,
        url: budget_investment_path(budget, investment)
      )

      expect(page).not_to have_field "I agree to the Privacy Policy and the Terms and conditions of use"
    end
  end
end
