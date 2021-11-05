module Consul
  class Application < Rails::Application
    config.i18n.default_locale = :ar
    config.i18n.available_locales = [:ar, :fr, :en]
    config.i18n.fallbacks = {
      "ar"    => "fr",
      "fr" => "ar",
      "en" => "fr"
    }
  end
end
