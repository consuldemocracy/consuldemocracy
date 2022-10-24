require "rails_helper"

describe Admin::BudgetInvestmentsController, :admin do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.budgets"] = false

      expect do
        get :index, params: { budget_id: create(:budget).id }
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end

    it "raises an error if budget slug is not found" do
      expect do
        get :index, params: { budget_id: "wrong_budget" }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises an error if budget id is not found" do
      expect do
        get :index, params: { budget_id: 0 }
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end

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
