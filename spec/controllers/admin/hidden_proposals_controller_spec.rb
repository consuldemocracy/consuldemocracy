require "rails_helper"

describe Admin::HiddenProposalsController, :admin do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.proposals"] = false

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end
end
