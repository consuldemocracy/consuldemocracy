module Consul
  class Application < Rails::Application
    config.i18n.default_locale = :fr
    config.time_zone = 'Europe/Paris'
    if Rails.env == 'test'
      config.i18n.available_locales = [:fr, :en]
    else
      config.i18n.available_locales = [:fr]
    end
  end
end
