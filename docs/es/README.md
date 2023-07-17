![Logotipo de CONSUL DEMOCRACY](../img/consul_logo.png)

# CONSUL DEMOCRACY

Aplicación de Participación Ciudadana y Gobierno Abierto

## Web CONSUL DEMOCRACY Project

Puedes acceder a la página principal del proyecto en [http://consuldemocracy.org](http://consuldemocracy.org) donde puedes encontrar documentación sobre el uso de la plataforma, videos y enlaces al espacio de la comunidad.

## Configuración para desarrollo y tests

**NOTA**: para unas instrucciones más detalladas consulta la [documentación](https://docs.consuldemocracy.org)

Prerequisitos: tener instalado git, Ruby 3.0.6, CMake, pkg-config, shared-mime-info, Node.js y PostgreSQL (9.5 o superior).

```bash
git clone https://github.com/consuldemocracy/consuldemocracy.git
cd consuldemocracy
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

## Licencia

El código de este proyecto está publicado bajo la licencia AFFERO GPL v3 (ver [LICENSE-AGPLv3.txt](open_source/license.md))

## Contribuciones

Ver fichero [CONTRIBUTING_ES.md](https://github.com/consuldemocracy/consuldemocracy/blob/master/CONTRIBUTING_ES.md)

## Desarrollo en local con Docker

Puedes leer la guía en [https://consul_docs.gitbooks.io/docs/content/es/getting_started/docker.html](https://consul_docs.gitbooks.io/docs/content/es/getting_started/docker.html)
