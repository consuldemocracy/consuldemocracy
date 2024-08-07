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
