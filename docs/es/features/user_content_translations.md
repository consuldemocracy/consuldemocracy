# Traducciones de contenido de usuario

## Traducciones remotas bajo demanda del usuario

Este servicio tiene como objetivo poder ofrecer todos los contenidos dinámicos de la aplicación (propuestas, debates, inversiones presupuestarias y comentarios) en diferentes idiomas sin la necesidad de que un usuario o un administrador haya creado cada una de sus traducciones.

Cuando un usuario accede a una pantalla con un idioma donde parte del contenido dinámico que está visualizando no tiene traducciones, dispondrá de un botón para solicitar la traducción de todo el contenido. Este contenido se enviará a un traductor automático (en este caso [Microsoft TranslatorText](https://azure.microsoft.com/es-es/products/cognitive-services/translator/)) y en cuanto se obtenga la respuesta, todas estas traducciones estarán disponibles para cualquier usuario.

### Cómo empezar

Para poder utilizar esta funcionalidad es necesario realizar los siguientes pasos:

1. Crear una [cuenta en Azure](https://azure.microsoft.com/es-es/).
2. Una vez que hayas iniciado sesión en el portal de Azure, crear un recurso del tipo _Translator Text_ (nota: esta implementación está pensada para que al crear el recurso se seleccione la región GLOBAL, de lo contrario será necesario personalizar las llamadas a la API añadiendo la región seleccionada).
3. Una vez subscrito al servicio de Translator Text, tendrás accesibles dos _API keys_ en la sección **Administración de recursos > Claves y punto de conexión** que serán necesarias para la configuración del servicio de traducciones en tu aplicación.

### Configuración

Para activar el servicio de traducciones en tu aplicación debes completar los siguientes pasos:

#### Añadir api key en la aplicación

En el apartado anterior hemos comentado que una vez subscritos al servicio de traducciones disponemos de dos _API keys_. Para configurar el servicio correctamente en nuestra aplicación deberemos añadir una de las dos _API keys_ en el archivo `secrets.yml`, en la sección `apis:`, con la clave `microsoft_api_key`, como podemos ver en la siguiente imagen:

```yml
apis: &apis
  census_api_end_point: ""
  census_api_institution_code: ""
  census_api_portal_code: ""
  census_api_user_code: ""
  sms_end_point: ""
  sms_username: ""
  sms_password: ""
  microsoft_api_key: "nueva_api_key_1_para_translator_text"
```

#### Activar funcionalidad

Una vez disponemos de la nueva key en el `secrets.yml` ya podemos proceder a activar la funcionalidad. Para activar la funcionalidad deberás acceder a través del panel de administración a la sección **Configuración > Configuración global > Funcionalidades** y activar la funcionalidad de **Traducciones Remotas**.

### Funcionalidad

Una vez tenemos la api key en nuestro `secrets.yml` y la funcionalidad activada, los usuarios ya podrán utilizar las traducciones remotas en la aplicación.

Para aclarar el funcionamiento, se adjuntan unos pantallazos de cómo interactúa la aplicación con nuestros usuarios:

* Cuando un usuario accede a una pantalla en un idioma en el que no están disponibles todas las traducciones, le aparecerá un texto en la parte superior de la pantalla y un botón para poder solicitar la traducción. (**Nota:** *En el caso de acceder con un idioma no soportado por el servicio de traducción no se mostrará ningún texto ni botón de traducción. Ver sección: Idiomas disponibles para la traducción remota*)

  ![Se muestra el texto "El contenido de esta página no esta disponible en tu idioma" y al lado el botón de traducción "Traducir página" en la parte superior de la página](../../img/translations/remote_translations/display-text-and-button-es.png)

* Una vez el usuario pulsa el botón de `Traducir página` se encolan las traducciones y se recarga la pantalla con un notice (*informando que se han solicitado correctamente las traducciones*) y un texto informativo en la cabecera (*explicando cuándo podrá ver estas traducciones*).

  ![Se informa al usuario que se han solicitado las traducciones](../../img/translations/remote_translations/display-notice-and-text-after-enqueued-es.png)

* Si un usuario accede a una pantalla que no dispone de traducciones pero ya han sido solicitadas por otro usuario, la aplicación no le mostrará el botón de traducir, pero sí un texto informativo en la cabecera (*explicando cuándo podrá ver estas traducciones*).

  ![Se informa al usuario que las traducciones están pendientes](../../img/translations/remote_translations/display-text-translations-pending-es.png)

* Las peticiones de traducción se delegan a `Delayed Job` y en cuanto haya sido procesada, el usuario después de refrescar su página podrá ver el contenido traducido.

  ![Se muestra el contenido traducido](../../img/translations/remote_translations/display-translated-content-es.png)

### Idiomas disponibles para la traducción remota

Actualmente estos son todos los [idiomas disponibles](https://api.cognitive.microsofttranslator.com/languages?api-version=3.0) en el servicio de traducción:

```yml
["af", "am", "ar", "as", "az", "ba", "bg", "bho", "bn", "bo", "brx", "bs", "ca", "cs", "cy", "da", "de", "doi", "dsb", "dv", "el", "en", "es", "et", "eu", "fa", "fi", "fil", "fj", "fo", "fr", "fr-CA", "ga", "gl", "gom", "gu", "ha", "he", "hi", "hne", "hr", "hsb", "ht", "hu", "hy", "id", "ig", "ikt", "is", "it", "iu", "iu-Latn", "ja", "ka", "kk", "km", "kmr", "kn", "ko", "ks", "ku", "ky", "ln", "lo", "lt", "lug", "lv", "lzh", "mai", "mg", "mi", "mk", "ml", "mn-Cyrl", "mn-Mong", "mni", "mr", "ms", "mt", "mww", "my", "nb", "ne", "nl", "nso", "nya", "or", "otq", "pa", "pl", "prs", "ps", "pt", "pt-PT", "ro", "ru", "run", "rw", "sd", "si", "sk", "sl", "sm", "sn", "so", "sq", "sr-Cyrl", "sr-Latn", "st", "sv", "sw", "ta", "te", "th", "ti", "tk", "tlh-Latn", "tlh-Piqd", "tn", "to", "tr", "tt", "ty", "ug", "uk", "ur", "uz", "vi", "xh", "yo", "yua", "yue", "zh-Hans", "zh-Hant", "zu"]
```

De todos los idiomas que actualmente tiene Consul Democracy definidos (`available_locales`) en `config/application.rb` el único que no está en la lista anterior y por lo tanto no se ofrece servicio de traducción es el valenciano `["val"]`.

### Costes

El servicio de traducción utilizado tiene los [precios](https://azure.microsoft.com/es-es/pricing/details/cognitive-services/translator/) más competitivos del mercado.
El precio por cada 1 Millón de caracteres traducidos asciende a 10 $ y sin ningún tipo de coste fijo al mes.

Aunque se han tomado medidas técnicas para evitar un mal uso de este servicio, recomendamos la creación de Alertas que ofrece Azure para que un Administrador pueda ser notificado en el caso de detectar un uso fuera de lo común del servicio. Este servicio tiene un coste de 0,10 $ al mes.

Para crear una Alerta en Azure debemos seguir los siguientes pasos:

1. Inicia sesión en **Azure Portal**.
1. Accede al servicio **Traductor** creado anteriormente.
1. Accede en el menú lateral a **Supervisión > Alertas**:
   1. Accedemos a **Crear regla de alertas**
   1. En **Selección de una señal** seleccionamos `Text Characters Translated`
   1. Una vez seleccionada debemos definir la lógica de la Alerta para que se ajuste a nuestras necesidades. Ej: Rellena el campo "Operador" con el valor "Mayor que", rellena el campo "Tipo de Agregación" con el valor "Total" y por último rellena el campo "Valor del umbral" por el número de caracteres que consideramos que deben traducirse antes de ser notificados. En esta sección también se puede configurar el periodo de tiempo y la frecuencia de evaluación.
   1. Para poder ser notificados tenemos que crear un **Grupo de Acciones** y asociarlo a esta Alerta que estamos creando. Para ello accedemos al botón de **Crear** y rellenamos el formulario. Como se puede observar hay diferentes tipos de acciones, debemos seleccionar **Correo electrónico/SMS/Insertar/Voz** y configurar la opción que consideremos conveniente según nuestras necesidades.
   1. Una vez creado este grupo de acciones, ya queda directamente asociado a la regla que estamos creando.
   1. Por último ya solo queda añadir un nombre y clicar sobre el botón **Revisar y crear**.

### Añadir un nuevo servicio de traducción

En el caso de que se quieran integrar más servicios de traducción por cualquier motivo (aparece uno nuevo en el mercado más competitivo, se quiere cambiar para contemplar los idiomas que actualmente no tienen soporte, etc) se ha dejado preparado el código para poder añadirlo con las mínimas modificaciones posibles.

Esto es posible gracias a la clase `RemoteTranslations::Caller` que es una capa intermedia entre la gestión de los contenidos sin traducir y el Cliente de traducción de Microsoft utilizado actualmente.

Una buena solución para añadir otro servicio de traducción sería sustituir la llamada al `MicrosoftTranslateClient` dentro del método `translations` del `RemoteTranslations::Caller` por el nuevo servicio implementado.

En caso de querer convivir con ambos sólo debería gestionarse en qué caso queremos utilizar uno u otro, ya sea mediante condiciones especificas en el código o mediante una gestión en los Settings de la aplicación.

```ruby
class RemoteTranslationsCaller

  ...
  def translations
    @translations ||= RemoteTranslations::Microsoft::Client.new.call(fields_values, locale)
    # Add new RemoteTranslations Client
    # @translations = RemoteTranslations::NewTranslateClient::Client.new.call(fields_values, locale_to)
  end
  ...

end
```

## Interfaz de traducción

Esta funcionalidad permite a los usuarios introducir contenidos dinámicos en diferentes idiomas a la vez. Cualquier usuario administrador de Consul Democracy puede activar o desactivar esta funcionalidad a través del panel de administración de la aplicación. Si desactivas esta funcionalidad (configuración de la funcionalidad por defecto) los usuarios sólo podrán introducir un idioma.

### Activar funcionalidad

Para activar la funcionalidad deberas acceder desde el panel de administración a la sección **Configuración > Configuración global > Funcionalidades** y activar el módulo de **Interfaz de traducción**.

### Casos de uso

Dependiendo de si activamos o desactivamos el módulo de **Interfaz de traducción** veremos los formularios de la siguiente manera:

* Cuando la interfaz de traducción está activa:
 Como podemos ver en la imagen a continuación la interfaz de traducción tiene 2 selectores, el primero "Seleccionar idioma" permite cambiar entre los lenguajes activos y el segundo selector "Añadir idioma" permite añadir nuevos idiomas al formulario. Los campos traducibles se pueden distinguir fácilmente mediante un fondo azul de los que no lo son.

 También disponemos de un botón `Eliminar idioma` para eliminar un idioma en caso de necesitarlo. Si un usuario elimina accidentalmente un idioma puede recuperarlo añadiendo dicho idioma otra vez al formulario.

 Esta funcionalidad está visible tanto para las páginas de creación como para las páginas de edición.

 ![Interfaz de traducción activada](../../img/translations/interface_translations/translations-interface-enabled-es.png)

* Cuando la interfaz de traducción está desactivada:
  Cuando esta funcionalidad está desactivada los formularios se renderizan sin la interfaz de traducción y sin resaltar los campos traducibles con fondo azul.

  ![Interfaz de traducción desactivada](../../img/translations/interface_translations/translations-interface-disabled-es.png)
