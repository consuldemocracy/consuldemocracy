module Consul
  class Application < Rails::Application
    config.i18n.default_locale = :he
    config.i18n.available_locales = [:he, :en, :ru, :ar]
  end
end