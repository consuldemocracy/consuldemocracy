require "rails_helper"

describe Moderation::DebatesController do
  before { sign_in(create(:moderator).user) }

  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.debates"] = false

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end
end
