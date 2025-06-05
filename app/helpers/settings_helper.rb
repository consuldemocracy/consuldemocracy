module SettingsHelper
  def oauth_logins
    [
      (:twitter if feature?(:twitter_login)),
      (:facebook if feature?(:facebook_login)),
      (:google_oauth2 if feature?(:google_login)),
      (:wordpress_oauth2 if feature?(:wordpress_login)),
      (:saml if feature?(:saml_login))
    ].compact
  end

  def feature?(name)
    setting["feature.#{name}"].presence || setting["process.#{name}"].presence || setting[name].presence
  end

  def setting
    @all_settings ||= Setting.all.to_h { |s| [s.key, s.value.presence] }
  end
end
