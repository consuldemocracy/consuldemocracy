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
end
