# Instalación manual en producción

**AVISO:** Recomendamos *no usar* este sistema, para el que no damos soporte oficial, ya que siempre que sea posible debe utilizarse el [instalador](https://github.com/consul/installer). Utiliza este método si usar el instalador no es una opción y si tienes experiencia configurando PostgreSQL, puma o passenger, NGNIX y SSL (con letsencrypt, por ejemplo).

Esta guía asume que ya has [instalado todas las dependencias necesarias](prerequisites.md) en tu sistema.

La estructura de directorios que se crea a continuación está pensada para usarse con [capistrano](https://capistranorb.com/documentation/getting-started/structure/).

## Estructura de directorios

En primer lugar, crea el directorio principal, clona el repositorio y crea los subdirectorios necesarios:

```
mkdir consul && cd consul
git clone --mirror https://github.com/consul/consul.git repo
mkdir releases shared
mkdir shared/log shared/tmp shared/config shared/public shared/storage
mkdir -p shared/public/assets shared/public/system shared/public/ckeditor_assets shared/public/machine_learning/data
```

## Versión inicial

Crea una primera carpeta en "releases" a partir del repositorio, junto con un enlace simbólico a la versión actual (sustituye `<latest_consul_stable_version>` por el número de la última versión estable de Consul Democracy, como 1.3.1 o 1.4.1):

```
cd repo
git archive <latest_consul_stable_version> | tar -x -f - -C ../releases/first
cd ..
ln -s releases/first current
```

## Instalación de gemas

Instala las gemas de las que depende Consul Democracy:

```
cd releases/first
bundle install --path ../../shared/bundle --without development test
cd ../..
```

## Ficheros de configuración

Genera los ficheros `database.yml` y `secrets.yml`:

```
cp current/config/secrets.yml.example shared/config/secrets.yml
cp current/config/database.yml.example shared/config/database.yml
cd releases/first/config
ln -s ../../../shared/config/database.yml
ln -s ../../../shared/config/secrets.yml
cd ../../..
```

Edita el fichero `shared/config/database.yml`, rellenando `username` y `password` con los datos generador durante la [configuración de PostgreSQL](debian.md#postgresql-94).

Ahora generamos una clave secreta:

```
cd current
bin/rake secret RAILS_ENV=production
cd ..
```

Copia la clave generada y edita el fichero `shared/config/secrets.yml`; en la sección `production`, cambia los siguientes datos:

```
  secret_key_base: introduce_la_clave_secreta_que_acabas_de_generar
  server_name: introduce_tu_dominio
```

Si no tienes un certificado SSL, cambia además `force_ssl: true` por `force_ssl: false`.

## Base de datos

Crea una base de datos, genera los datos necesarios para que la aplicación funcione y compila los ficheros de CSS y JavaScript:

```
 cd current
 bin/rake db:migrate RAILS_ENV=production
 bin/rake db:seed RAILS_ENV=production
 bin/rake assets:precompile RAILS_ENV=production
```

## Arranque de la aplicación

Y, por último, inicia el servidor de Rails:

```
bin/rails s -e production
```

¡Enhorabuena! Ahora tu servidor está funcionando en el entorno de producción :smile:.
