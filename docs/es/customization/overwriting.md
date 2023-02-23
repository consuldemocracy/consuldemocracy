# Adaptar application.rb

Cuando necesites extender o modificar el `config/application.rb` puedes hacerlo a través del fichero `config/application_custom.rb`. Por ejemplo si quieres modificar el idioma por defecto al inglés pondrías lo siguiente:

```ruby
module Consul
  class Application < Rails::Application
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :es]
  end
end
```

Recuerda que para ver reflejado estos cambios debes reiniciar el servidor de desarrollo.
