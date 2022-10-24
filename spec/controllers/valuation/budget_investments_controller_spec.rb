require "rails_helper"

describe Valuation::BudgetInvestmentsController do
  let(:valuator) { create(:valuator) }
  let(:budget) { create(:budget, valuators: [valuator]) }
  before { sign_in(valuator.user) }

  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.budgets"] = false

      expect do
        get :index, params: { budget_id: budget.id }
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

  describe "GET show" do
    it "is not visible for not assigned valuators" do
      investment = create(:budget_investment, budget: budget)
      login_as create(:valuator).user

      expect do
        get :show, params: { budget_id: budget.id, id: investment.id }
      end.to raise_error ActionController::RoutingError
    end
  end
end
