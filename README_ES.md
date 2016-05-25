![Logotipo de Consul]
(https://raw.githubusercontent.com/consul/consul/master/public/consul_logo.png)

# Consul

Aplicación de Participación Ciudadana y Gobierno Abierto

[![Build Status](https://travis-ci.org/consul/consul.svg?branch=master)](https://travis-ci.org/consul/consul)
[![Code Climate](https://codeclimate.com/github/consul/consul/badges/gpa.svg)](https://codeclimate.com/github/consul/consul)
[![Dependency Status](https://gemnasium.com/consul/consul.svg)](https://gemnasium.com/consul/consul)
[![Coverage Status](https://coveralls.io/repos/consul/consul/badge.svg?branch=master&service=github)](https://coveralls.io/github/consul/consul?branch=master)

Este es el repositorio de código abierto de la Aplicación de Participación Ciudadana Consul, creada originariamente por el Ayuntamiento de Madrid.

## Estado del proyecto

El desarrollo de esta aplicación comenzó el [15 de Julio de 2015](https://github.com/consul/consul/commit/8db36308379accd44b5de4f680a54c41a0cc6fc6) y el código fue puesto en producción el día 7 de Septiembre de 2015 en [decide.madrid.es](https://decide.madrid.es). Desde entonces se le añaden mejoras y funcionalidades constantemente. La evolución y futura lista de funcionalidades a implementar se pueden consultar en la lista de [tareas por hacer](https://github.com/consul/consul/issues).

## Hoja de ruta

Ver fichero [ROADMAP_ES.md](ROADMAP_ES.md)

## Tecnología

El backend de esta aplicación se desarrolla con el lenguaje de programación [Ruby](https://www.ruby-lang.org/) sobre el *framework* [Ruby on Rails](http://rubyonrails.org/).
Las herramientas utilizadas para el frontend no están cerradas aún. Los estilos de la página usan [SCSS](http://sass-lang.com/) sobre [Foundation](http://foundation.zurb.com/)

## Configuración para desarrollo y tests

Prerequisitos: tener instalado git, Ruby 2.2.3, la gema `bundler`, ghostscript y PostgreSQL (9.4 o superior).

```

git clone https://github.com/consul/consul.git
cd consul
bundle install
cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml
rake db:create
bin/rake db:setup
bin/rake db:dev_seed
RAILS_ENV=test rake db:setup
```

Para ejecutar la aplicación en local:
```
bin/rails s
```

Prerequisitos para los tests: tener instalado PhantomJS >= 1.9.8

Para ejecutar los tests:

```
bin/rspec
```

Puedes usar el usuario administrador por defecto del fichero seeds:

 **user:** admin@madrid.es
 **pass:** 12345678

Pero para ciertas acciones, como apoyar, necesitarás un usuario verificado, el fichero seeds proporciona uno:

 **user:** verified@madrid.es
 **pass:** 12345678


### OAuth

Para probar los servicios de autenticación mediante proveedores externos OAuth — en este momento Twitter, Facebook y Google —, necesitas crear una "aplicación" en cada una de las plataformas soportadas y configurar la *key* y el *secret* proporcionados en tu *secrets.yml*

En el caso de Google, comprueba que las APIs *Contacts API* y *Google+ API* están habilitadas para la aplicación.

## Licencia

El código de este proyecto está publicado bajo la licencia AFFERO GPL v3 (ver [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt))

## Contribuciones

Ver fichero [CONTRIBUTING_ES.md](CONTRIBUTING_ES.md)
