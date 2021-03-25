require "rails_helper"

describe Admin::BudgetInvestmentsController, :admin do
  describe "PATCH update" do
    it "does not redirect on AJAX requests" do
      investment = create(:budget_investment)

      patch :update, params: {
        id: investment,
        budget_id: investment.budget,
        format: :json,
        budget_investment: { visible_to_valuators: true }
      }

      expect(response).not_to be_redirect
    end
  end
end
