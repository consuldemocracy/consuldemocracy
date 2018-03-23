module Consul
  class Application < Rails::Application
    config.i18n.default_locale = :fr
    config.time_zone = 'Europe/Paris'
    # English needed for Faver dev_seeds
    if Rails.env.test? || Rails.env.development?
      config.i18n.available_locales = [:fr, :en]
    else
      config.i18n.available_locales = [:fr]
    end
  end
end
