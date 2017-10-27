module Consul
  class Application < Rails::Application

    config.i18n.available_locales = [:es]
    config.i18n.fallbacks = {}
  end
end
