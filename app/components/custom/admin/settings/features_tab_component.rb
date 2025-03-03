load Rails.root.join("app","components","admin","settings","features_tab_component.rb")

class Admin::Settings::FeaturesTabComponent < ApplicationComponent
  alias_method :original_settings, :settings

  def settings
    custom_settings = %w[ feature.saml_login
                          feature.valid_geozone
                          feature.demographics
                          feature.hide_local_login
                        ]
    original_settings + custom_settings
  end
end
