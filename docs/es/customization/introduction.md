# Personalización

Puedes modificar Consul Democracy y ponerle tu propia imagen, para esto debes primero [crear tu propio fork](../getting_started/create.md).

Hemos creado una estructura específica donde puedes sobreescribir y personalizar la aplicación para que puedas actualizar sin que tengas problemas al hacer merge y se sobreescriban por error tus cambios. Intentamos que Consul Democracy sea una aplicación Ruby on Rails lo más plain vanilla posible para facilitar el acceso de nuevas desarrolladoras.

## Ficheros y directorios especiales

Para adaptar tu fork de Consul Democracy puedes utilizar alguno de los directorios `custom` que están en las rutas:

* `app/assets/images/custom/`
* `app/assets/javascripts/custom/`
* `app/assets/stylesheets/custom/`
* `app/components/custom/`
* `app/controllers/custom/`
* `app/form_builders/custom/`
* `app/graphql/custom/`
* `app/lib/custom/`
* `app/mailers/custom/`
* `app/models/custom/`
* `app/models/custom/concerns/`
* `app/views/custom/`
* `config/locales/custom/`
* `spec/components/custom/`
* `spec/controllers/custom/`
* `spec/models/custom/`
* `spec/routing/custom/`
* `spec/system/custom/`

Aparte de estos directorios, también puedes utilizar los siguientes ficheros:

* `app/assets/javascripts/custom.js`
* `app/assets/stylesheets/custom.css`
* `app/assets/stylesheets/_custom_settings.css`
* `app/assets/stylesheets/_consul_custom_overrides.css`
* `config/application_custom.rb`
* `config/environments/custom/development.rb`
* `config/environments/custom/preproduction.rb`
* `config/environments/custom/production.rb`
* `config/environments/custom/staging.rb`
* `config/environments/custom/test.rb`
* `Gemfile_custom`

## Ejecutar los tests

Al personalizar el código, es **muy importante** que todos los tests de la aplicación sigan pasando. En caso contrario, habrá fallos al actualizar a una nueva versión de Consul Democracy (o incluso al actualizar los cambios personalizados) y estos fallos no serán detectados hasta que el código esté ya ejecutándose en producción. Consul Democracy incluye más de 6000 tests que comprueban la manera en que se comporta la aplicación; sin ellos, sería imposible asegurarse de que el código nuevo no rompe comportamientos existentes.

Así que, en primer lugar, asegúrate de haber [configurado tu "fork"](../getting_started/configuration.md) para que utilice un sistema de integración continua que ejecute todos los tests cada vez que hagas cambios en el código. Recomendamos ejecutar estos tests en una rama de desarrollo abriendo una "pull request" (también llamada "merge request") para que los tests se ejecuten antes de que los cambios personalizados se añadan a la rama `master`.

En caso de que alguno de los tests falle, echa un vistazo a uno de los tests y comprueba si falla por un fallo en el código personalizado o porque el test comprueba un comportamiento que ha cambiado con los cambios personalizados (por ejemplo, puede que modifiques el código para que solamente los usuarios verificados puedan añadir comentarios, pero puede que haya un test que compruebe que cualquier usuario puede añadir comentarios, ya que es el comportamiento por defecto). Si el test falla debido a un fallo en el código personalizado, arréglalo ;). Si falla debido a un comportamiento que ha cambiado, consulta la sección de [personalización de tests](tests.md).

**Recomendamos encarecidamente añadir tests a tus cambios personalizados** para que tengas una forma de comprobar si estos cambios siguen funcionando cuando actualices a una nueva versión de Consul Democracy.
