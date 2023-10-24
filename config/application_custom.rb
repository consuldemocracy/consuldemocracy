module Consul
  class Application < Rails::Application
    config.time_zone = "Vilnius"
    config.i18n.available_locales = [:lt, :en]
    config.i18n.default_locale = :lt

  end
end
