require "rails_helper"

describe Admin::HiddenDebatesController, :admin do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.debates"] = false

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  describe "PUT confirm_hide" do
    it "keeps query parameters while using protected redirects" do
      debate = create(:debate, :hidden)

      get :confirm_hide, params: { id: debate, filter: "all", host: "evil.dev" }

      expect(response).to redirect_to "/admin/hidden_debates?filter=all"
    end
  end

  describe "PUT restore" do
    it "keeps query parameters while using protected redirects" do
      debate = create(:debate, :hidden, :with_confirmed_hide)

      get :restore, params: { id: debate, filter: "all", host: "evil.dev" }

      expect(response).to redirect_to "/admin/hidden_debates?filter=all"
    end
  end
end
