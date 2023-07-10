# Traducciones y Textos

## Traducciones

Actualmente Consul Democracy esta traducido total o parcialmente a multiples idiomas, visita el proyecto en [Crowdin](https://crowdin.com/project/consul)

[Únete a los traductores](https://crwd.in/consul) para ayudar a completar los existentes, o contacta con nosotros a través del [gitter de Consul Democracy](https://gitter.im/consul/consul) para convertirte en Revisor y validar las contribuciones de los traductores.

En el caso de que tu lenguage no este presente en el proyecto de Crowdin, por favor [abre una incicencia](https://github.com/consul/consul/issues/new?title=New language&body=Hello I would like to have my language INSERT YOUR LANGUAGE NAME added to Consul Democracy) y lo añadiremos rápidamente.

Si quieres ver las traducciones de los textos de la web, puedes encontrarlos en los ficheros formato YML disponibles en `config/locales/`. Puedes leer la [guía de internacionalización](http://guides.rubyonrails.org/i18n.html) de Ruby on Rails sobre como funciona este sistema.

## Textos personalizados

Dado que Consul Democracy está en evolución continua con nuevas funcionalidades, y para que mantener tu fork actualizado sea más sencillo, recomendamos no modificar los ficheros de traducciones, es una mejor idea "sobreescribirlos" usando ficheros personalizados en caso de necesidad de alterar un texto.

Así pues las adaptaciones las debes poner en el directorio `config/locales/custom/`, recomendamos poner solo los textos que quieras personalizar. Por ejemplo si quieres personalizar el texto de "Ayuntamiento de Madrid, 2016" que se encuentra en el footer en todas las páginas, primero debemos ubicar en que plantilla se encuentra (`app/views/layouts/_footer.html.erb`), vemos que en el código pone lo siguiente:

```ruby
<%= t("layouts.footer.copyright", year: Time.current.year) %>
```

Y que en el fichero `config/locales/es/general.yml` sigue esta estructura (solo ponemos lo relevante para este caso):

```yml
es:
  layouts:
    footer:
      copyright: Ayuntamiento de Madrid, %{year}

```

Si creamos el fichero `config/locales/custom/es/general.yml` y modificamos "Ayuntamiento de Madrid" por el nombre de la organización que se este haciendo la modificación. Recomendamos directamente copiar los ficheros `config/locales/` e ir revisando y corrigiendo las que querramos, borrando las líneas que no querramos traducir.

## Mantener tus Textos Personalizados y Lenguajes

Consul Democracy tiene la gema [i18n-tasks](https://github.com/glebm/i18n-tasks), es una herramienta estupenda para gestionar textos i18n. Prueba en tu consola `i18n-tasks health` para ver un reporte de estado.

Si tienes un lenguaje propio diferente al Inglés, deberias añadirlo al fichero de configuración [i18n-tasks.yml para las variables `base_locale` y `locales`](https://github.com/consul/consul/blob/master/config/i18n-tasks.yml#L4-L7) de forma que los ficheros de tu idioma también sean comprobados.
