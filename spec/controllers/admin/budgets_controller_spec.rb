require "rails_helper"

describe Admin::BudgetsController, :admin do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.budgets"] = false

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  describe "GET edit" do
    it "raises an error if budget slug is not found" do
      expect do
        get :edit, params: { id: "wrong_budget" }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises an error if budget id is not found" do
      expect do
        get :edit, params: { id: 0 }
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end

  describe "DELETE destroy" do
    let(:budget) { create(:budget) }

    it "allows destroying budgets without investments but with administrators and valuators" do
      budget.administrators << Administrator.first
      budget.valuators << create(:valuator)

      delete :destroy, params: { id: budget }

      expect(response).to redirect_to admin_budgets_path
      expect(flash[:notice]).to eq "Budget deleted successfully"
      expect(Budget.count).to eq 0
      expect(BudgetAdministrator.count).to eq 0
      expect(BudgetValuator.count).to eq 0
    end

    it "does not destroy budgets with investments" do
      create(:budget_investment, budget: budget)

      delete :destroy, params: { id: budget }

      expect(response).to redirect_to admin_budget_path(budget)
      expect(flash[:alert]).to eq "You cannot delete a budget that has associated investments"
      expect(Budget.all).to eq [budget]
    end

    it "does not destroy budgets with a poll" do
      create(:poll, budget: budget)

      delete :destroy, params: { id: budget }

      expect(response).to redirect_to admin_budget_path(budget)
      expect(flash[:alert]).to eq "You cannot delete a budget that has an associated poll"
      expect(Budget.all).to eq [budget]
    end
  end
end
