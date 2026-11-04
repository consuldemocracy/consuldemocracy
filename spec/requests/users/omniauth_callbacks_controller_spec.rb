require "rails_helper"

describe Users::OmniauthCallbacksController do
  describe "GET /users/auth/twitter/callback" do
    it "does not create two users with two simultaneous requests", :race_condition do
      Setting["feature.twitter_login"] = true
      OmniAuth.config.add_mock(:twitter, { uid: "12345", info: { name: "tweety" }})
      path = user_twitter_omniauth_callback_path

      2.times.map do
        Thread.new { get path }
      end.each(&:join)

      users = User.where(username: "tweety")

      expect(users.count).to eq 1
      expect(Identity.find_by!(uid: "12345", provider: "twitter").user).to eq users.first
    end
  end
end
