# Personalización de la configuración de la aplicación

## Personalizar application.rb

Cuando necesites extender o modificar el `config/application.rb`, puedes hacerlo a través del fichero `config/application_custom.rb`. Por ejemplo, si quieres modificar la zona horaria de la aplicación para que utilice la de las Islas Canarias, añade:

```ruby
module Consul
  class Application < Rails::Application
    config.time_zone = "Atlantic/Canary"
  end
end
```

En este caso concreto, la zona horaria de la aplicación también puede modificarse editando el fichero `config/secrets.yml`.

Recuerda que para ver reflejados estos cambios debes reiniciar la aplicación.

## Personalizar la configuración de los entornos

Para personalizar los entornos de desarrollo, test, "staging", preproducción o producción, puedes editar los ficheros en `config/environments/custom/`.

Ten en cuenta que los cambios en `config/environments/custom/production.rb` se aplicarán también a los entornos de "staging" y de preproducción, y que los cambios en `config/environments/custom/staging.rb` se aplicarán también al entorno de preproducción.

Y recuerda que para ver reflejados estos cambios debes reiniciar la aplicación.
