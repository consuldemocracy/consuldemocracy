# Personalización

Puedes modificar CONSUL y ponerle tu propia imagen, para esto debes primero [crear tu propio fork](forks/create.md).

Hemos creado una estructura específica donde puedes sobreescribir y personalizar la aplicación para que puedas actualizar sin que tengas problemas al hacer merge y se sobreescriban por error tus cambios. Intentamos que CONSUL sea una aplicación Ruby on Rails lo más plain vanilla posible para facilitar el acceso de nuevas desarrolladoras.

## Ficheros y directorios especiales

Para adaptar tu fork de CONSUL puedes utilizar alguno de los directorios `custom` que están en las rutas:

* `config/locales/custom/`
* `app/assets/images/custom/`
* `app/views/custom/`
* `app/controllers/custom/`
* `app/models/custom/`

Aparte de estos directorios también cuentas con ciertos ficheros para:

* `app/assets/stylesheets/custom.css`
* `app/assets/stylesheets/_custom_settings.css`
* `app/assets/javascripts/custom.js`
* `Gemfile_custom`
* `config/application.custom.rb`

## Interfaz de traducción

Esta funcionalidad permite a los usuarios introducir contenidos dinámicos en diferentes idiomas a la vez. Cualquier usuario administrador de Consul puede activar o desactivar esta funcionalidad a través del panel de administración de la aplicación. Si desactivas esta funcionalidad (configuración de la funcionalidad por defecto) los usuarios sólo podrán introducir un idioma.

#### Activar funcionalidad
Para activar la funcionalidad deberá realizar 2 pasos:
1. Ejecutar el siguiente comando `bin/rake settings:create_translation_interface_setting RAILS_ENV=production` (Este paso sólo es necesario para instalaciones de Consul existentes que incorporan esta funcionalidad, para nuevas instalaciones no es necesario)
1. Accedediendo como usuario administrador a través del panel de administración de su aplicación a la sección **Configuración > Funcionalidades** y activando el módulo de **Interfaz de traducción** como se puede ver a continuación:
![Active interface translations](../../img/translations/interface_translations/active-interface-translations-es.png)

#### Casos de uso
Dependiendo de si activamos o desactivamos el módulo de **Interfaz de traducción** veremos los formularios accesibles por el usuario de la siguiente manera:

* Cuando la interfaz de traducción esta activa:
Como podemos ver en la imagen a continuación la interfaz de traducción tiene 2 selectores, el primero "Seleccionar idioma" permite cambiar entre los lenguajes activos y el segundo selector "Añadir idioma" permite añadir nuevos idiomas al formulario. Los campos traducibles se pueden distinguir fácilmente mediante un fondo azul de los que no lo son. También disponemos de un botón `Eliminar idioma` para eliminar un idioma en caso de necesitarlo. Si un usuario elimina accidentalmente un idioma puede recuperarlo añadiendo dicho idioma otra vez al formulario.
Esta funcionalidad está visible tanto para las páginas de creación como para las páginas de edición.
![Translations inteface enabled](../../img/translations/interface_translations/translations-interface-enabled-es.png)

* Cuando la interfaz de traducción esta desactivada:
Cuando esta funcionalidad está desactivada los formularios se renderizan sin la interfaz de traducción y sin resaltar los campos traducibles con fondo azul.
![Translations inteface enabled](../../img/translations/interface_translations/translations-interface-disabled-es.png)
