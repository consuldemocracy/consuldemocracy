# Configuración para los entornos de desarrollo y pruebas  (GNU/Linux)

## Git

Git es mantenido oficialmente en Debian/Ubuntu:

```
sudo apt-get install git
```

## Ruby

Las versiones de Ruby versions empaquetadas en repositorios oficiales no son aptas para trabajar con consul (al menos Debian 7 y 8), así que debemos instalar manualmente.

El método recomendado es via rvm:

(sólo la opción multiusuario instala todas las dependencias automáticamente, al usar 'sudo'.)

### Como usuario local

```
curl -L https://get.rvm.io | bash -s stable
```

### Para todos los usuarios del sistema

```
curl -L https://get.rvm.io | sudo bash -s stable
```

añadismos nuestro usuario al grupo de rvm

```
sudo usermod -a -G rvm <user>
```

y finalmente, añadimos el script rvm a nuestro bash (~/.bashrc) (este paso sólo es necesario si no puedes ejecutar el comando rvm)

```
[[ -s /usr/local/rvm/scripts/rvm ]] && source /usr/local/rvm/scripts/rvm
```

con todo esto, deberías poder instalar la versión de ruby con rvm, por ejemplo la 2.3.2:

```
sudo rvm install 2.3.2
```

## Bundler

usando

```
gem install bundler
```

hay varios métodos alternativos [aquí](https://rvm.io/integration/bundler) que podrían ser mejores como:

```
gem install rubygems-bundler
```

## PostgreSQL (>=9.4)

La versión 9.4 de PostgreSQL no es oficial en Debian 7 (wheezy), pero en Debian 8 parece ser mantenida oficialmente.

Así que debemos añadir el respositorio oficial de postgresql a apt, por ejemplo creando el fichero */etc/apt/sources.list.d/pgdg.list* con:

```
deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main
```

después deberás descargar la key e instalarla:

```
wget https://www.postgresql.org/media/keys/ACCC4CF8.asc
apt-key add ACCC4CF8.asc
```

y finalmente instalar postgresql

```
apt-get update
apt-get install postgresql-9.4
```

## Ghostscript

```
apt-get install ghostscript
```

## Clonar el repositorio

Ahora que ya tenemos todas las dependencias instalado podemos bajarnos el proyecto:

```
git clone https://github.com/consul/consul.git
cd consul
bundle install
cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml
```

Ahora copia en `database.yml` el usuario y la contraseña que pusiste para *consul*. Cuando ya lo hayas hecho:

```
rake db:create
rake db:setup
rake db:dev_seed
RAILS_ENV=test bin/rake db:setup
```

Para ejecutar los tests:

```
bundle exec rspec
```

Quizás necesites crear un rol de superusuario en postgresql, y completar en el fichero*/config/database.yml* los campos 'user:' y 'password:'.

Además, parece que postgresql usa un socket unix por defecto para las comunicaciones en local. Si te encuentras este problema creando la base de datos, cambia en */config/database.yml* la linea:

```
host: localhost
```

por:

```
host: /var/run/postgresql
```

Tras esto en el terminal ejecutaremos:

```
rake db:create
rake db:setup
rake db:dev_seed
RAILS_ENV=test bin/rake db:setup
```

Y por último para comprobar que todo esta bien, lanza los tests:

```
bundle exec rspec
```
