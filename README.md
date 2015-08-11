# Aplicación de Participación Ciudadana del Ayuntamiento de Madrid

[![Build Status](https://travis-ci.org/AyuntamientoMadrid/participacion.svg?branch=master)](https://travis-ci.org/AyuntamientoMadrid/participacion)
[![Code Climate](https://codeclimate.com/github/AyuntamientoMadrid/participacion/badges/gpa.svg)](https://codeclimate.com/github/AyuntamientoMadrid/participacion)
[![Dependency Status](https://gemnasium.com/AyuntamientoMadrid/participacion.svg)](https://gemnasium.com/AyuntamientoMadrid/participacion)
[![Coverage Status](https://coveralls.io/repos/AyuntamientoMadrid/participacion/badge.svg?branch=master&service=github)](https://coveralls.io/github/AyuntamientoMadrid/participacion?branch=master)

Este es el repositorio de código abierto de la Aplicación de Participación Ciudadana del Ayuntamiento de Madrid.

## Estado del proyecto

El desarrollo de esta aplicación comenzó el [15 de Julio de 2015](https://github.com/AyuntamientoMadrid/participacion/commit/8db36308379accd44b5de4f680a54c41a0cc6fc6)

Este proyecto está en las primeras fases de su desarrollo. Las funcionalidades actualmente presentes en el código, así como sus nombres, deben considerarse como provisionales.

## Tecnología

El backend de esta aplicación se desarrolla con el lenguaje de programación [Ruby](https://www.ruby-lang.org/) sobre el *framework* [Ruby on Rails](http://rubyonrails.org/).
Las herramientas utilizadas para el frontend no están cerradas aún. Los estilos de la página usan [SCSS](http://sass-lang.com/) sobre [Foundation](http://foundation.zurb.com/)

## Configuración para desarrollo y tests

Prerequisitos: tener instalado git, ImageMagick, Ruby 2.2.2, la gema `bundler`, y una librería moderna de PostgreSQL.

```
cd participacion
bundle install
cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml
bundle exec bin/rake db:setup
RAILS_ENV=test bundle exec rake db:setup
```

Para ejecutar la aplicación en local:
```
bundle exec bin/rails s
```

Para ejecutar los tests:
```
bundle exec bin/rspec
```

## Licencia

El código de este proyecto está publicado bajo la licencia MIT (ver MIT-license.md)

## Contribuciones

Ver fichero [CONTRIBUTING.md](CONTRIBUTING.md)
