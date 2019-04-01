# Configuración para los entornos de desarrollo y pruebas (GNU/Linux)

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

## Node.js

Para compilar los archivos estáticos (JS, CSS, imágenes, etc.), es necesario un _runtime_ de JavaScript. Node.js es la opción recomendada. Al igual que como ocurre con Ruby, no es recomendable instalar Node directamente de los repositorios de tu distribución Linux.

Para instalar Node, puedes usar [n](https://github.com/tj/n)

Ejecuta el siguiente comando en tu terminal:

```
curl -L https://git.io/n-install | bash -s -- -y lts
```

Y este instalará automáticamente la versión LTS (_Long Term Support_, inglés para "Soporte a largo plazo") más reciente de Node en tu directorio `$HOME` (Este comando hace uso de [n-install](https://github.com/mklement0/n-install))

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

## ChromeDriver

Para realizar pruebas de integración, usamos Selenium junto a Headless Chrome.

En distribuciones basadas en Debian, el proceso de instalar ChromeDriver no es tan sencillo como en Mac OS.

Para ello, primero instala los siguientes paquetes:

```bash
sudo apt-get update && sudo apt-get install libxss1 libappindicator1 libindicator7 unzip
```

Ahora necesitarás Google Chrome o Chromium. Ambas opciones son válidas.

Puedes instalar el primero haciendo click [acá](https://www.google.com/chrome/index.html), mientras que el segundo puede ser instalado de la siguiente manera:

```bash
sudo apt-get install chromium
```

Ahora puedes instalar ChromeDriver. Primero, comprueba su última versión haciendo click [acá](https://sites.google.com/a/chromium.org/chromedriver/)

Descárgalo ejecutando el siguiente comando:

```bash
wget -N http://chromedriver.storage.googleapis.com/2.37/chromedriver_linux64.zip
```

Descomprimelo y hazlo ejecutable:

```bash
unzip chromedriver_linux64.zip
chmod +x chromedriver
```

Finalmente, añade el binario a tu `$PATH`:

```bash
sudo mv -f chromedriver /usr/local/share/chromedriver
sudo ln -s /usr/local/share/chromedriver /usr/local/bin/chromedriver
sudo ln -s /usr/local/share/chromedriver /usr/bin/chromedriver
```

Asegúrate de que todo funciona como es debido ejecutando el siguiente comando:

```bash
chromedriver --version
```

Deberías recibir un mensaje indicando la última versión de ChromeDriver. Si ese es el caso, está todo listo

Si te encuentras usando una distro basada en Arch, instalando `chromium` desde el repositorio `extra` debería ser suficiente

También tienes la opción de solo instalar ChromeDriver desde AUR. Si usas `pacaur`, ejecuta el siguiente comando:

```bash
pacaur -S chromedriver
```

> Ya estás listo para [instalar Consul](../local_installation.html)!!
