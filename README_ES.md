![Logotipo de CONSUL DEMOCRACY](https://raw.githubusercontent.com/consuldemocracy/consuldemocracy/master/public/consul_logo.png)

# CONSUL DEMOCRACY

Aplicación de Participación Ciudadana y Gobierno Abierto

[![Insignia DPG](https://img.shields.io/badge/Verified-DPG-3333AB?logo=data:image/svg%2bxml;base64,PHN2ZyB3aWR0aD0iMzEiIGhlaWdodD0iMzMiIHZpZXdCb3g9IjAgMCAzMSAzMyIgZmlsbD0ibm9uZSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj4KPHBhdGggZD0iTTE0LjIwMDggMjEuMzY3OEwxMC4xNzM2IDE4LjAxMjRMMTEuNTIxOSAxNi40MDAzTDEzLjk5MjggMTguNDU5TDE5LjYyNjkgMTIuMjExMUwyMS4xOTA5IDEzLjYxNkwxNC4yMDA4IDIxLjM2NzhaTTI0LjYyNDEgOS4zNTEyN0wyNC44MDcxIDMuMDcyOTdMMTguODgxIDUuMTg2NjJMMTUuMzMxNCAtMi4zMzA4MmUtMDVMMTEuNzgyMSA1LjE4NjYyTDUuODU2MDEgMy4wNzI5N0w2LjAzOTA2IDkuMzUxMjdMMCAxMS4xMTc3TDMuODQ1MjEgMTYuMDg5NUwwIDIxLjA2MTJMNi4wMzkwNiAyMi44Mjc3TDUuODU2MDEgMjkuMTA2TDExLjc4MjEgMjYuOTkyM0wxNS4zMzE0IDMyLjE3OUwxOC44ODEgMjYuOTkyM0wyNC44MDcxIDI5LjEwNkwyNC42MjQxIDIyLjgyNzdMMzAuNjYzMSAyMS4wNjEyTDI2LjgxNzYgMTYuMDg5NUwzMC42NjMxIDExLjExNzdMMjQuNjI0MSA5LjM1MTI3WiIgZmlsbD0id2hpdGUiLz4KPC9zdmc+Cg==)](https://www.digitalpublicgoods.net/r/consul-democracy)
[![Licencia: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](http://www.gnu.org/licenses/agpl-3.0)
[![Cumplimiento de las normas de accesibilidad](https://img.shields.io/badge/accessibility-WAI:AA-green.svg)](https://www.w3.org/WAI/eval/Overview)

![Estado de los tests](https://github.com/consuldemocracy/consuldemocracy/workflows/tests/badge.svg)
[![Cobertura de código](https://coveralls.io/repos/github/consuldemocracy/consuldemocracy/badge.svg)](https://coveralls.io/github/consuldemocracy/consuldemocracy?branch=master)
[![Crowdin](https://d322cqt584bo4o.cloudfront.net/consul/localized.svg)](https://translate.consuldemocracy.org/)
[![CI paralela Knapsack Pro para tests RSpec](https://img.shields.io/badge/Knapsack%20Pro-Parallel%20/%20RSpec%20tests-%230074ff)](https://knapsackpro.com/dashboard/organizations/176/projects/202/test_suites/318/builds?utm_campaign=organization-id-176&utm_content=test-suite-id-318&utm_medium=readme&utm_source=knapsack-pro-badge&utm_term=project-id-202)

[![Se busca ayuda](https://img.shields.io/badge/help-wanted-brightgreen.svg?style=flat-square)](https://github.com/consuldemocracy/consuldemocracy/issues?q=is%3Aopen+label%3A"help+wanted")

Este es el repositorio de código abierto de la Aplicación de Participación Ciudadana CONSUL DEMOCRACY, creada originariamente por el Ayuntamiento de Madrid y actualmente mantenido por la comunidad de software libre en colaboración con la Fundación CONSUL DEMOCRACY.

## Documentación

Por favor visita la [documentación que está siendo completada](https://docs.consuldemocracy.org/index/spanish) para conocer más sobre este proyecto, cómo comenzar tu propio fork, instalarlo, personalizarlo y usarlo como administrador/mantenedor.

## Fundación CONSUL DEMOCRACY y página web del proyecto

Puedes acceder a la página principal del proyecto en [http://consuldemocracy.org](http://consuldemocracy.org/es) donde puedes encontrar información sobre el uso de la plataforma, la Fundación CONSUL DEMOCRACY, la comunidad de usuarios y socios locales, noticias y formas de obtener más ayuda o ponerte en contacto con nosotros.

## Apoya el Proyecto

Si utilizas Consul Democracy, compartes nuestra misión y valores, o simplemente quieres ayudarnos a seguir desarrollando software libre, ¡considera apoyarnos!

**[Apoya Consul Democracy](https://opencollective.com/consuldemocracy)**

## Configuración para desarrollo y tests

**NOTA**:
El proceso de instalación varía según el sistema operativo. Por favor, consulta la [documentación de instalación local](docs/es/installation/local_installation.md) apropiada para tu SO.

Prerrequisitos: tener instalado git, Ruby 3.4.9, CMake, pkg-config, Node.js 22.22.3, ImageMagick y PostgreSQL (>=13).

**Nota**: Es posible que ejecutar `bin/setup`, como se indica a continuación, falle si has configurado un nombre de usuario y contraseña para PostgreSQL. Si es así, edita las líneas que contienen `username:` y `password:` (añadiendo tus credenciales) en el fichero `config/database.yml` y ejecuta `bin/setup` de nuevo.

```bash
git clone https://github.com/consuldemocracy/consuldemocracy.git
cd consuldemocracy
bin/setup
bin/rake db:dev_seed
```

Para ejecutar la aplicación en local:

```bash
bin/rails s
```

Para ejecutar los tests:

```bash
bin/rspec
```

Nota: ejecutar todos los tests en tu máquina puede tardar más de una hora, por lo que recomendamos encarecidamente que configures un sistema de Integración Continua para ejecutarlos utilizando varios trabajos en paralelo cada vez que abras o modifiques una PR (si usas GitHub Actions o GitLab CI, esto ya está configurado en `.github/workflows/tests.yml` y `.gitlab-ci.yml`) y cuando trabajes en tu máquina ejecutes solamente los tests relacionados con tu desarrollo actual. Al configurar la aplicación por primera vez, recomendamos que ejecutes al menos un test en `spec/models/` y un test en `spec/system/` para comprobar que tu máquina está configurada para ejecutar los tests correctamente.

Puedes usar el usuario administrador por defecto del fichero seeds:

 **user:** admin@consul.dev
 **pass:** 12345678

Pero para ciertas acciones, como apoyar, necesitarás un usuario verificado, el fichero seeds proporciona uno:

 **user:** verified@consul.dev
 **pass:** 12345678

## Configuración para entornos de producción

Ver [instalador](https://github.com/consuldemocracy/installer)

## Estado del proyecto

El desarrollo de esta aplicación comenzó el [15 de Julio de 2015](https://github.com/consuldemocracy/consuldemocracy/commit/8db36308379accd44b5de4f680a54c41a0cc6fc6) y el código fue puesto en producción el día 7 de Septiembre de 2015 en [decide.madrid.es](https://decide.madrid.es). Desde entonces se le añaden mejoras y funcionalidades constantemente. Las funcionalidades actuales se pueden consultar en la [página del proyecto](http://consuldemocracy.org/es) y las futuras funcionalidades en el [Roadmap](https://github.com/orgs/consuldemocracy/projects/2) y [el listado de issues](https://github.com/consuldemocracy/consuldemocracy/issues).

## Licencia

El código de este proyecto está publicado bajo la licencia AFFERO GPL v3 (ver [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt))

## Contribuciones

Ver fichero [CONTRIBUTING_ES.md](CONTRIBUTING_ES.md)
