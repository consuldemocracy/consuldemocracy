module Consul
  class Application < Rails::Application
    config.i18n.default_locale = :fr
    config.i18n.available_locales = [:fr ]
  end
end
