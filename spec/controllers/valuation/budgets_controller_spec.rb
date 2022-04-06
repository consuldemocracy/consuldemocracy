require "rails_helper"

describe Valuation::BudgetsController do
  before { sign_in(create(:valuator).user) }

  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.budgets"] = false

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end
end
