module Consul
  class Application < Rails::Application
    config.i18n.available_locales = [:lt, :en]
    config.i18n.default_locale = :lt
    config.time_zone = "Europe/Vilnius"

  end
end
