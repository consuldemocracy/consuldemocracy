# Traducciones

Actualmente Consul esta traducido total o parcialmente a multiples idiomas, visita el proyecto en [Crowdin](https://crowdin.com/project/consul)

[Únete a los traductores](https://crwd.in/consul) para ayudar añadir un nuevo lenguage o completar los existentes, o contacta con nosotros a través del [gitter de consul](https://gitter.im/consul/consul) para convertirte en Revisor y validar las contribuciones de los traductores.

Si quieres ver las traducciones de los textos de la web, puedes encontrarlos en los ficheros formato YML disponibles en `config/locales/`. Puedes leer la [guía de internacionalización](http://guides.rubyonrails.org/i18n.html) de Ruby on Rails sobre como funciona este sistema.

# Textos

Las adaptaciones los debes poner en el directorio `config/locales/custom/`, recomendamos poner solo los textos que quieras personalizar. Por ejemplo si quieres personalizar el texto de "Ayuntamiento de Madrid, 2016" que se encuentra en el footer en todas las páginas, primero debemos ubicar en que plantilla se encuentra (`app/views/layouts/_footer.html.erb`), vemos que en el código pone lo siguiente:

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
