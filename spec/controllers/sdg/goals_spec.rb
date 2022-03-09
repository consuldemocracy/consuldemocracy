require "rails_helper"

describe SDG::GoalsController do
  context "featured disabled" do
    before do
      Setting["feature.sdg"] = false
    end

    it "raises feature disabled" do
      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end
end
