require "rails_helper"

describe Devise::OmniauthFormComponent do
  describe "#oauth_logins" do
    let(:component) { Devise::OmniauthFormComponent.new("sign_up") }

    before do
      Setting["feature.facebook_login"] = false
      Setting["feature.twitter_login"] = false
      Setting["feature.google_login"] = false
      Setting["feature.wordpress_login"] = false
      Setting["feature.saml_login"] = false
    end

    it "is not rendered when all authentications are disabled" do
      render_inline component

      expect(page).not_to be_rendered
    end

    it "renders the twitter link when the feature is enabled" do
      Setting["feature.twitter_login"] = true

      render_inline component

      expect(page).to have_button "Twitter"
      expect(page).to have_button count: 1
    end

    it "renders the facebook link when the feature is enabled" do
      Setting["feature.facebook_login"] = true

      render_inline component

      expect(page).to have_button "Facebook"
      expect(page).to have_button count: 1
    end

    it "renders the google link when the feature is enabled" do
      Setting["feature.google_login"] = true

      render_inline component

      expect(page).to have_button "Google"
      expect(page).to have_button count: 1
    end

    it "renders the wordpress link when the feature is enabled" do
      Setting["feature.wordpress_login"] = true

      render_inline component

      expect(page).to have_button "Wordpress"
      expect(page).to have_button count: 1
    end

    it "renders the SAML link when the feature is enabled" do
      Setting["feature.saml_login"] = true

      render_inline component

      expect(page).to have_button "SAML"
      expect(page).to have_button count: 1
    end
  end
end
