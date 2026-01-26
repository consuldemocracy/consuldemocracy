require "rails_helper"

describe Users::OmniauthCallbacksController do
  before { request.env["devise.mapping"] = Devise.mappings[:user] }

  let(:user) { create(:user, email: "oauth@consul.org", username: "oauthuser") }
  let(:twitter_auth_hash) do
    OmniAuth::AuthHash.new(
      provider: "twitter",
      uid: "12345",
      info: {
        name: "OAuth User",
        email: "oauth@consul.org"
      }
    )
  end

  describe "access logs" do
    before do
      allow(Rails.application.config).to receive(:authentication_logs).and_return(true)
      Setting["feature.twitter_login"] = true
      request.env["omniauth.auth"] = twitter_auth_hash
      create(:identity, uid: "12345", provider: "twitter", user: user)
    end

    it "when an OAuth sign in process succeeds it calls the authentication logger" do
      message = "The user #{user.email} with IP address: 0.0.0.0 successfully signed in."
      expect(AuthenticationLogger).to receive(:log).with(message)

      get :twitter
    end
  end
end
