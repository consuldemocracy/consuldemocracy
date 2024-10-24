# Personalización de traducciones y textos

## Traducciones

Actualmente Consul Democracy está traducido total o parcialmente a múltiples idiomas. Visita el [proyecto en Crowdin](https://translate.consuldemocracy.org/) para comprobar el estado de las traducciones.

[Únete a los traductores](https://crwd.in/consul) para ayudar a completar los idiomas existentes, o contacta con nosotros a través de [las conversaciones de Consul Democracy](https://github.com/consuldemocracy/consuldemocracy/discussions) para convertirte en revisor y validar las contribuciones de los traductores.

En el caso de que tu idioma no esté presente en el proyecto de Crowdin, por favor [abre una incidencia](https://github.com/consuldemocracy/consuldemocracy/issues/new?title=New%20language&body=Hello%20I%20would%20like%20to%20have%20my%20language%20INSERT%20YOUR%20LANGUAGE%20NAME%20added%20to%20Consul%20Democracy) y lo añadiremos rápidamente.

Si quieres ver las traducciones de los textos de la web, puedes encontrarlos en los ficheros en formato YAML disponibles en `config/locales/`. Puedes leer la [guía de internacionalización](http://guides.rubyonrails.org/i18n.html) de Ruby on Rails para aprender cómo funciona este sistema.

## Textos personalizados

Dado que Consul Democracy está en evolución continua con nuevas funcionalidades, y para que mantener tu "fork" actualizado sea más sencillo, recomendamos no modificar los ficheros de traducciones sino sobrescribirlos usando ficheros personalizados en caso de que quieras cambiar un texto.

Así que, para cambiar algunos de los textos existentes, puedes añadir tus cambios en el directorio `config/locales/custom/`. Recomendamos encarecidamente poner solamente los textos que quieras personalizar en lugar de copiar todo el contenido del archivo original. Por ejemplo, si quieres personalizar el texto "CONSUL DEMOCRACY, 2024" (o el año actual) que se encuentra en el pie de página, primero debemos encontrar dónde se utiliza (en este caso, `app/components/layouts/footer_component.html.erb`), y comprobar el identificador de traducción que aparece en el código:

```erb
<%= t("layouts.footer.copyright", year: Time.current.year) %>
```

Localiza el fichero en el que se encuentra este identificador (en este caso, `config/locales/es/general.yml`) y crea un archivo en `config/locales/custom/` (en este caso, crea el archivo `config/locales/custom/es/general.yml`) con el siguiente contenido:

```yml
es:
  layouts:
    footer:
      copyright: Tu Organización, %{year}
```

Es importante que los ficheros de `config/locales/custom/` solamente incluyan textos personalizados y no los textos originales. De este modo, será más fácil actualizar a una nueva versión de Consul Democracy.

## Mantener tus textos personalizados y lenguajes

Consul Democracy utiliza la gema [i18n-tasks](https://github.com/glebm/i18n-tasks), que es una herramienta estupenda para gestionar traducciones. Ejecuta en una consola `i18n-tasks health` para ver un informe de estado.

Si tienes un idioma propio diferente al inglés, deberías añadirlo a las variables `base_locale` y `locales` del [fichero de configuración i18n-tasks.yml](https://github.com/consuldemocracy/consuldemocracy/blob/master/config/i18n-tasks.yml#L3-L6), de forma que los ficheros de tu idioma también sean comprobados.
