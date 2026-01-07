# Personalización del Gemfile

Para añadir gemas (herramientas externas escritas en Ruby) nuevas puedes editar el fichero `Gemfile_custom`. Por ejemplo, si quieres añadir la gema [rails-footnotes](https://github.com/josevalim/rails-footnotes), añade:

```ruby
gem "rails-footnotes", "~> 4.0"
```

Tras esto, ejecuta `bundle install` y sigue los pasos de instalación específicos de la gema que aparecerán en su documentación.

**Nota**: es posible que aparezcan conflictos al hacer un update a una nueva versión de Consul. En repositorios donde no se hayan añadido demasiadas gemas custom, lo mejor es primero aceptar el Gemfile.lock de la nueva versión y luego hacer `bundle install`. Es recomendable ser específico con las versiones en las gemas en el Gemfile_custom. De esta manera, esas gemas no serán actualizadas al hacer un `bundle install`.
