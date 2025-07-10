module Consul
  class Application < Rails::Application
    # Idioma por defecto
    config.i18n.default_locale = :es

    # Idiomas disponibles
    config.i18n.available_locales = [:es]

    # Ruta por defecto que utilizará la aplicación
    config.root_directory = "/presupuestosparticipativos"
    config.assets.prefix = "/presupuestosparticipativos/assets/"
  end
end
