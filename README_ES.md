<!--
  Title: CONSUL
  Description: Aplicación de Participación Ciudadana y Gobierno Abierto
  Keywords: democracia, participación ciudadana, participación electrónica, debates, propuestas, votaciones, consultas, legislación colaborativa, presupuestos participativos
-->

![Logotipo de CONSUL](https://raw.githubusercontent.com/consul/consul/master/public/consul_logo.png)

# CONSUL

Aplicación de Participación Ciudadana y Gobierno Abierto

![Estado de los tests](https://github.com/consul/consul/workflows/tests/badge.svg)
[![Code Climate](https://codeclimate.com/github/consul/consul/badges/gpa.svg)](https://codeclimate.com/github/consul/consul)
[![Coverage Status](https://coveralls.io/repos/github/consul/consul/badge.svg?branch=master)](https://coveralls.io/github/consul/consul?branch=master)
[![Crowdin](https://d322cqt584bo4o.cloudfront.net/consul/localized.svg)](https://crowdin.com/project/consul)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](http://www.gnu.org/licenses/agpl-3.0)

[![Accessibility conformance](https://img.shields.io/badge/accessibility-WAI:AA-green.svg)](https://www.w3.org/WAI/eval/Overview)
[![A11y issues checked with Rocket Validator](https://rocketvalidator.com/badges/checked_with_rocket_validator.svg?url=https://rocketvalidator.com)](https://rocketvalidator.com/opensource)

[![Join the chat at https://gitter.im/consul/consul](https://badges.gitter.im/consul/consul.svg)](https://gitter.im/consul/consul?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Help wanted](https://img.shields.io/badge/help-wanted-brightgreen.svg?style=flat-square)](https://github.com/consul/consul/issues?q=is%3Aissue+is%3Aopen+label%3A"help+wanted")

Este es el repositorio de código abierto de la Aplicación de Participación Ciudadana CONSUL, creada originariamente por el Ayuntamiento de Madrid.

## Documentación

Por favor visita la documentación que está siendo completada en [https://docs.consulproject.org](https://docs.consulproject.org) para conocer más sobre este proyecto, cómo comenzar tu propio fork, instalarlo, personalizarlo y usarlo como administrador/mantenedor.

## Web CONSUL Project

Puedes acceder a la página principal del proyecto en [http://consulproject.org](http://consulproject.org) donde puedes encontrar documentación sobre el uso de la plataforma, videos y enlaces al espacio de la comunidad.

## Configuración para desarrollo y tests

**NOTA**: para unas instrucciones más detalladas consulta la [documentación](https://docs.consulproject.org)

Prerequisitos: tener instalado git, Ruby 2.6.6, Node.js y PostgreSQL (9.4 o superior).

```bash
git clone https://github.com/consul/consul.git
cd consul
bundle install
cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml
bin/rake db:create
bin/rake db:migrate
bin/rake db:dev_seed
RAILS_ENV=test rake db:setup
```

Para ejecutar la aplicación en local:

```
bin/rails s
```

Para ejecutar los tests:

```
bin/rspec
```

Puedes usar el usuario administrador por defecto del fichero seeds:

 **user:** admin@consul.dev
 **pass:** 12345678

Pero para ciertas acciones, como apoyar, necesitarás un usuario verificado, el fichero seeds proporciona uno:

 **user:** verified@consul.dev
 **pass:** 12345678

## Estado del proyecto

El desarrollo de esta aplicación comenzó el [15 de Julio de 2015](https://github.com/consul/consul/commit/8db36308379accd44b5de4f680a54c41a0cc6fc6) y el código fue puesto en producción el día 7 de Septiembre de 2015 en [decide.madrid.es](https://decide.madrid.es). Desde entonces se le añaden mejoras y funcionalidades constantemente. Las funcionalidades actuales se pueden consultar en la [la página del projecto](http://consulproject.org/es) y las futuras funcionalidades en el [Roadmap](https://github.com/consul/consul/projects/6) y [el listado de issues](https://github.com/consul/consul/issues).

## Licencia

El código de este proyecto está publicado bajo la licencia AFFERO GPL v3 (ver [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt))

## Contribuciones

Ver fichero [CONTRIBUTING_ES.md](CONTRIBUTING_ES.md)

## Desarrollo en local con Docker

Puedes leer la guía en [https://consul_docs.gitbooks.io/docs/content/es/getting_started/docker.html](https://consul_docs.gitbooks.io/docs/content/es/getting_started/docker.html)
