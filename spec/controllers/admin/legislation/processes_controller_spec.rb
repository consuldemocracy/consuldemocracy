require "rails_helper"

describe Admin::Legislation::ProcessesController, :admin do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.legislation"] = false

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end
end
