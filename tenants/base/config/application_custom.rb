module Consul
  class Application < Rails::Application
    config.i18n.default_locale = :nl
    config.i18n.available_locales = ["nl"]
    config.multitenancy = true
  end
end
