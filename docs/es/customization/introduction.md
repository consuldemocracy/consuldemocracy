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

## Traducciones remotas bajo demanda del usuario

Este servicio tiene como objetivo poder ofrecer todos los contenidos dinámicos de la aplicación(propuestas, debates, inversiones presupuestarias y comentarios) en diferentes idiomas sin la necesidad de que un usuario ó un administrador haya creado cada una de sus traducciones.

Cuando un usuario accede a una pantalla con un idioma donde parte del contenido dinámico que esta visualizando no tiene traducciones, dispondrá de un botón para solicitar la traducción de todo el contenido. Este contenido se enviará a un traductor automático (en este caso [Microsoft TranslatorText](https://azure.microsoft.com/es-es/services/cognitive-services/translator-text-api/)) y en cuanto se obtenga la respuesta, todas estas traducciones estarán disponibles para cualquier usuario.

#### Como empezar
Para poder utilizar esta funcionalidad es necesario realizar los siguientes pasos:
1. Disponer de una api key para conectarse con el servicio de traducción. Para ello necesitamos una [cuenta en Azure](https://azure.microsoft.com/es-es/)
1. Una vez que haya iniciado sesión en el portal de Azure, subscríbase a Translator Text API en Microsoft Cognitive Service.
1. Una vez subscrito al servicio de Translator Text, tendrá accesibles 2 api keys en la sección **RESOURCE MANAGEMENT > Keys** que serán necesarias para la configuración del servicio de traducciones en su aplicación.

#### Configuración
Para activar el servicio de traducciones en su aplicación debe completar los siguientes pasos

##### Añadir api key en la aplicación
En el apartado anterior hemos comentado que una vez subscritos al servicio de traducciones disponemos de 2 api keys. Para configurar el servicio correctamente en nuestra aplicación deberemos añadir una de las dos api keys en el archivo `secrets.yml` en la sección `apis:` con la key `microsoft_api_key` como podemos ver en la siguiente imágen:

![Add api key to secrets](../../img/translations/remote_translations/add-api-key-to-secrets.png)

##### Activar funcionalidad
Una vez disponemos de la nueva key en el `secrets.yml` ya podemos proceder a activar la funcionalidad. Podemos activarla de dos maneras diferentes con idéntico resultado:
1. Accediendo a través del panel de administración de su aplicación en la sección **Configuración > Funcionalidades** y activar el módulo de **Traducciones Remotas** como se puede ver a continuación:
![Active remote translations](../../img/translations/remote_translations/active-remote-translations-es.png)
1. O bien ejecutando el siguiente comando `bin/rake settings:enable_remote_translations RAILS_ENV=production`

Con ambas opciones se activa el módulo y empezará a estar operativa la funcionalidad para nuestros usuarios.

#### Funcionalidad
Una vez tenemos la api key en nuestro `secrets.yml` y el módulo activado, los usuarios ya podrán utilizar la funcionalidad.
Para aclarar el funcionamiento, se adjuntan unos pantallazos de como interactua la aplicación con nuestros usuarios:
* Cuando un usuario accede a una pantalla en un idioma en el que no están disponibles todas las traducciones, le aparecerá un texto en la parte superior de la pantalla y un botón para poder solicitar la traducción. (**Nota:** *En el caso de acceder con un idioma no soportado por el servicio de traducción no se mostrará ningún texto ni botón de traducción. Ver sección: Idiomas disponibles para la traducción remota*)
![Display text and button](../../img/translations/remote_translations/display-text-and-button-es.png)

* Una vez el usuario pulsa el botón de `Traducir página` se encolan las traducciones y se recarga la pantalla con un notice (*informando que se han solicitado correctamente las traducciones*) y un texto informativo en la cabecera (*explicando cuando podrá ver estas traducciones*).
![Display notice and text after enqueued translations](../../img/translations/remote_translations/display-notice-and-text-after-enqueued-es.png)

* Si un usuario accede a una pantalla que no dispone de traducciones pero ya han sido solicitadas por otro usuario. La aplicación no le mostrará el botón de traducir, pero si un texto informativo en la cabecera (*explicando cuando podrá ver estas traducciones*).
![Display text explaining that translations are pending](../../img/translations/remote_translations/display-text-translations-pending-es.png)

* Las peticiones de traducción se delegan a `Delayed Job` y en cuanto haya sido procesada, el usuario después de refrescar su página podrá ver el contenido traducido.
![Display translated content](../../img/translations/remote_translations/display-translated-content-es.png)


#### Idiomas disponibles para la traducción remota
Actualmente estos son todos los [idiomas disponibles](https://docs.microsoft.com/es-es/azure/cognitive-services/translator/quickstart-ruby-languages) en el servicio de traducción:
```yml
["af", "ar", "bg", "bn", "bs", "ca", "cs", "cy", "da", "de", "el", "en", "es", "et", "fa", "fi", "fil", "fj", "fr", "he", "hi", "hr", "ht", "hu", "id", "is", "it", "ja", "ko", "lt", "lv", "mg", "ms", "mt", "mww", "nb", "nl", "otq", "pl", "pt", "ro", "ru", "sk", "sl", "sm", "sr-Cyrl", "sr-Latn", "sv", "sw", "ta", "te", "th", "tlh", "to", "tr", "ty", "uk", "ur", "vi", "yua", "yue", "zh-Hans", "zh-Hant"]
```
De todos los idiomas que actualmente tiene Consul definidos(`available_locales`) en `config/application.rb` no están incluidos en la lista anterior y por lo tanto no se ofrece servicio de traducción para los siguientes idiomas:
```yml
["val", "gl", "sq"]
```

#### Costes
El servicio de traducción utilizado tiene los [precios](https://azure.microsoft.com/es-es/pricing/details/cognitive-services/translator-text-api/) más competitivos del mercado.
El precio por cada 1 Millón de caracteres traducidos asciende a 8,43 € y sin ningún tipo de coste fijo al mes.
La competencia Google y DeepL tienen un precio aproximado de entre 16,00 € y 20,00 € por cada 1 Millón de caracteres más un fijo mensual.

Aunque el precio parece asequible para un Ayuntamiento, se pueden crear Alertas sobre varios parametros, entre ellos el `Número de caracteres traducidos` dentro del panel de administración de Azure en el apartado de **Supervisión**.

#### Añadir un nuevo servicio de traducción
En el caso de que se quieran integrar más servicios de traducción por cualquier motivo (aparece un nuevo en el mercado más competitivo, se quiere cambiar para contemplar los idiomas que actualmente no tienen soporte, etc) se ha dejado preparado el código para poder añadirlo con las mínimas modificaciones posibles.
Esto es posible gracias a la class `RemoteTranslationsCaller` que es una capa intermedia entre la gestión de los contenidos sin traducir y el Cliente de traducción de Microsoft utilizado actualmente.
Una buena solución para añadir otro servicio de traducción sería sustituir la llamada al `MicrosoftTranslateClient` dentro del método `call` del `RemoteTranslationsCaller` por el nuevo servicio implementado.
En caso de querer convivir con ambos sólo debería gestionarse en que caso queremos utilizar uno u otro, ya sea mediante condiciones especificas en el código o mediante una gestión en los Settings de la aplicación.

```ruby
class RemoteTranslationsCaller
  attr_accessor :available_remote_locales

  def call(remote_translation)
    resource = remote_translation.remote_translatable
    fields_values = prepare_fields_values(resource)
    locale_to = remote_translation.locale

    translations = MicrosoftTranslateClient.new.call(fields_values, locale_to)
    #Add new Translate Client
    #translations = NewTranslateClient.new.call(fields_values, locale_to)


    update_resource(resource, translations, locale_to)
    destroy_remote_translation(resource, remote_translation)
  end

  ...

end
```  
