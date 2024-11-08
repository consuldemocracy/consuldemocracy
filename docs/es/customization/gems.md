# Personalización del Gemfile

Para añadir gemas (herramientas externas escritas en Ruby) nuevas puedes editar el fichero `Gemfile_custom`. Por ejemplo, si quieres añadir la gema [rails-footnotes](https://github.com/josevalim/rails-footnotes), añade:

```ruby
gem "rails-footnotes", "~> 4.0"
```

Tras esto, ejecuta `bundle install` y sigue los pasos de instalación específicos de la gema que aparecerán en su documentación.
