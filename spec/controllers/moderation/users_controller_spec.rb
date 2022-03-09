require "rails_helper"

describe Moderation::UsersController do
  before { sign_in create(:moderator).user }

  describe "PUT hide_in_moderation_screen" do
    it "keeps query parameters while using protected redirects" do
      user = create(:user, email: "user@consul.dev")

      get :hide_in_moderation_screen, params: { id: user, search: "user@consul.dev", host: "evil.dev" }

      expect(response).to redirect_to "/moderation/users?search=user%40consul.dev"
    end
  end
end
