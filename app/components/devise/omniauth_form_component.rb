class Devise::OmniauthFormComponent < ApplicationComponent
  attr_reader :action

  def initialize(action)
    @action = action
  end

  def render?
    oauth_logins.any?
  end

  private

    def oauth_logins
      [
        (:twitter if feature?(:twitter_login)),
        (:facebook if feature?(:facebook_login)),
        (:google_oauth2 if feature?(:google_login)),
        (:wordpress_oauth2 if feature?(:wordpress_login)),
        (:saml if feature?(:saml_login)),
        (:oidc if feature?(:oidc_login))
      ].compact
    end
end
