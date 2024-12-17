# Instalación manual en producción

**AVISO:** Recomendamos *no usar* este sistema, para el que no damos soporte oficial, ya que siempre que sea posible debe utilizarse el [instalador](https://github.com/consuldemocracy/installer). Utiliza este método solo si usar el instalador no es una opción y si tienes experiencia configurando PostgreSQL, Puma o Passenger, NGNIX y SSL (con letsencrypt, por ejemplo).

Esta guía asume que ya has [instalado todas las dependencias necesarias](prerequisites.md) en tu sistema. Asegúrate de instalar RVM para poder instalar la versión de ruby necesaria para el proyecto que está definida en el fichero .ruby-version y también asegúrate de instalar FNM para poder instalar la versión de node.js definida en el fichero .node-version.

La estructura de directorios que se crea a continuación está pensada para usarse con [capistrano](https://capistranorb.com/documentation/getting-started/structure/).

## Estructura de directorios

En primer lugar, crea el directorio principal, clona el repositorio y crea los subdirectorios necesarios:

```bash
mkdir consul && cd consul
git clone --mirror https://github.com/consuldemocracy/consuldemocracy.git repo
mkdir releases shared
mkdir shared/log shared/tmp shared/config shared/public shared/storage
mkdir -p shared/public/assets shared/public/system shared/public/ckeditor_assets shared/public/machine_learning/data
```

## Versión inicial

Crea una carpeta en _releases_ a partir del repositorio y luego genera un enlace simbólico a la versión actual. Asegúrate de sustituir `<latest_consul_stable_version>` por el número de la última versión estable de Consul Democracy, como 2.1.1 o 2.2.0. Para encontrar la versión más reciente, visita la sección de _releases_ en el [repositorio de Consul Democracy](https://github.com/consuldemocracy/consuldemocracy/releases):

```bash
mkdir releases/first
cd repo
git archive <latest_consul_stable_version> | tar -x -f - -C ../releases/first
cd ..
ln -s releases/first current
```

## Instalación de dependencias

Instala las dependencias de Consul Democracy:

```bash
cd releases/first
bundle install --path ../../shared/bundle --without development test
fnm exec npm install
cd ../..
```

## Ficheros de configuración

Genera los ficheros `database.yml` y `secrets.yml`:

```bash
cp current/config/secrets.yml.example shared/config/secrets.yml
cp current/config/database.yml.example shared/config/database.yml
cd releases/first/config
ln -s ../../../shared/config/database.yml
ln -s ../../../shared/config/secrets.yml
cd ../../..
```

Edita el fichero `shared/config/database.yml`, rellenando `username` y `password` con los datos generador durante la [configuración de PostgreSQL](debian.md#postgresql).

Ahora generamos una clave secreta:

```bash
cd current
bin/rake secret RAILS_ENV=production
cd ..
```

Copia la clave generada y edita el fichero `shared/config/secrets.yml`; en la sección `production`, cambia los siguientes datos:

```yaml
  secret_key_base: introduce_la_clave_secreta_que_acabas_de_generar
  server_name: introduce_tu_dominio
```

Si no tienes un certificado SSL, cambia además `force_ssl: true` por `force_ssl: false`.

## Base de datos

Crea una base de datos, genera los datos necesarios para que la aplicación funcione y compila los ficheros de CSS y JavaScript:

```bash
 cd current
 bin/rake db:create RAILS_ENV=production
 bin/rake db:migrate RAILS_ENV=production
 bin/rake db:seed RAILS_ENV=production
 bin/rake assets:precompile RAILS_ENV=production
```

## Arranque de la aplicación

Y, por último, inicia el servidor de Rails:

```bash
bin/rails s -e production
```

¡Enhorabuena! Ahora tu servidor está funcionando en el entorno de producción :smile:.
