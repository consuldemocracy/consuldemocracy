require "rails_helper"

describe Admin::Poll::PollsController, :admin do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.polls"] = false

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end
end
