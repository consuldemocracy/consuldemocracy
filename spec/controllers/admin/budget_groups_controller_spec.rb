require "rails_helper"

describe Admin::BudgetGroupsController, :admin do
  describe "GET new" do
    it "raises an exception when the feature is disabled" do
      Setting["process.budgets"] = false

      expect do
        get :new, params: { budget_id: create(:budget).id }
      end.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  describe "GET edit" do
    let(:group) { create(:budget_group) }

    it "raises an error if budget slug is not found" do
      expect do
        get :edit, params: { budget_id: "wrong_budget", id: group.id }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises an error if budget id is not found" do
      expect do
        get :edit, params: { budget_id: 0, id: group.id }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises an error if group slug is not found" do
      expect do
        get :edit, params: { budget_id: group.budget.id, id: "wrong_group" }
      end.to raise_error ActiveRecord::RecordNotFound
    end

    it "raises an error if group id is not found" do
      expect do
        get :edit, params: { budget_id: 0, id: "wrong_group" }
      end.to raise_error ActiveRecord::RecordNotFound
    end
  end
end
