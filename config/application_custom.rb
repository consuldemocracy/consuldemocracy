module Consul
  class Application < Rails::Application
    config.i18n.default_locale = :ar
    config.i18n.available_locales = [:ar, :en, :fr]
    config.i18n.fallbacks = {
      "ar"    => "fr",
      "fr" => "en",
      "en" => "fr"
    }
  end
end
