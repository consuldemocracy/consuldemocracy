# Personalización de otras clases de Ruby

Aparte de modelos, controladores y componentes, hay otros directorios que contienen código de Ruby:

* `app/form_builders/`
* `app/graphql/`
* `app/lib/`
* `app/mailers/`

Los ficheros en estos directorios pueden personalizarse como cualquier otro fichero de Ruby (véase [personalización de modelos](models.md) para más información).

Por ejemplo, para personalizar el fichero `app/form_builders/consul_form_builder.rb`, crea el archivo `app/form_builders/custom/consul_form_builder.rb` con el siguiente contenido:

```ruby
load Rails.root.join("app", "form_builders", "consul_form_builder.rb")

class ConsulFormBuilder
  # Your custom logic here
end
```

O, para personalizar el fichero `app/lib/remote_translations/caller.rb`, crea el archivo `app/lib/custom/remote_translations/caller.rb` con el siguiente contenido:

```ruby
load Rails.root.join("app", "lib", "remote_translations", "caller.rb")

class RemoteTranslations::Caller
  # Your custom logic here
end
```
