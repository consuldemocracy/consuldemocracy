require "rails_helper"

describe DebatesController do
  describe "GET index" do
    it "raises an exception when the feature is disabled" do
      Setting["process.debates"] = false

      expect { get :index }.to raise_exception(FeatureFlags::FeatureDisabled)
    end
  end

  describe "POST create" do
    before do
      InvisibleCaptcha.timestamp_enabled = false
    end

    after do
      InvisibleCaptcha.timestamp_enabled = true
    end

    it "creates an ahoy event" do
      debate_attributes = {
        terms_of_service: "1",
        translations_attributes: {
          "0" => {
            title: "A sample debate",
            description: "this is a sample debate",
            locale: "en"
          }
        }
      }
      sign_in create(:user)

      post :create, params: { debate: debate_attributes }
      expect(Ahoy::Event.where(name: :debate_created).count).to eq 1
      expect(Ahoy::Event.last.properties["debate_id"]).to eq Debate.last.id
    end
  end

  describe "Vote with too many anonymous votes" do
    it "allows vote if user is allowed" do
      Setting["max_ratio_anon_votes_on_debates"] = 100
      debate = create(:debate)
      sign_in create(:user)

      expect do
        post :vote, xhr: true, params: { id: debate.id, value: "yes" }
      end.to change { debate.reload.votes_for.size }.by(1)
    end

    it "does not allow vote if user is not allowed" do
      Setting["max_ratio_anon_votes_on_debates"] = 0
      debate = create(:debate, cached_votes_total: 1000)
      sign_in create(:user)

      expect do
        post :vote, xhr: true, params: { id: debate.id, value: "yes" }
      end.not_to change { debate.reload.votes_for.size }
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
