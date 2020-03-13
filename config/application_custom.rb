module Consul
  class Application < Rails::Application
    # Idioma por defecto
    config.i18n.default_locale = :es

    # Idiomas disponibles
    available_locales = [:es]
  end
end
