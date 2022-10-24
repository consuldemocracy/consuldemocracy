require "rails_helper"

describe Admin::HiddenBudgetInvestmentsController, :admin do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.budgets"] = nil

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end
end
