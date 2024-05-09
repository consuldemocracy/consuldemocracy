require "rails_helper"

describe DebatesController do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.debates"] = false

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  describe "PUT mark_featured" do
    it "ignores query parameters" do
      debate = create(:debate)
      sign_in create(:administrator).user

      get :mark_featured, params: { id: debate, controller: "proposals" }

      expect(response).to redirect_to debates_path
    end
  end
end
