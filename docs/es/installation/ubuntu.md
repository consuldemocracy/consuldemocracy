# Configuración para los entornos de desarrollo y pruebas (Ubuntu 18.04)

## Actualización de sistema

Ejecuta una actualización general de las librerías de sistema:

```bash
sudo apt update
```

## Git

Git es mantenido oficialmente en Ubuntu:

```bash
sudo apt install git
```

## Gestor de versiones de Ruby

Las versiones de Ruby empaquetadas en repositorios oficiales no son aptas para trabajar con Consul Democracy, así que debemos instalarlo manualmente.

En primer lugar, necesitamos los siguiente paquetes para poder instalar Ruby:

```bash
sudo apt install libssl-dev autoconf bison build-essential libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev
```

A continuación instalaremos un gestor de versiones de Ruby, como rbenv:

```bash
wget -q https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer -O- | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
```

## Node.js

Para compilar los archivos estáticos (JS, CSS, imágenes, etc.), es necesario un _runtime_ de JavaScript. Node.js es la opción recomendada.

Ejecuta en tu terminal:

```bash
sudo apt install nodejs
```

## PostgreSQL

Instala postgresql y sus dependencias de desarrollo con:

```bash
sudo apt install postgresql libpq-dev
```

Para el correcto funcionamiento de Consul Democracy, necesitas confgurar un usuario para tu base de datos. Como ejemplo, crearemos un usuario llamado "consul":

```bash
sudo -u postgres createuser consul --createdb --superuser --pwprompt
```

Para asegurarse que se utiliza la codificación con UTF-8, crea un archivo:

```
sudo nano /etc/profile.d/lang.sh
```

Añade las siguientes líneas:

```
export LANGUAGE="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
```

Reconfigura Postgres para utilizar la codificación UTF-8:

`````
sudo su - postgres
psql

update pg_database set datistemplate=false where datname='template1';
drop database Template1;
create database template1 with owner=postgres encoding='UTF-8'
lc_collate='en_US.utf8' lc_ctype='en_US.utf8' template template0;
update pg_database set datistemplate=true where datname='template1';

\q
exit
`````

## Imagemagick

Instala Imagemagick:

```bash
sudo apt install imagemagick
```

## ChromeDriver

Para realizar pruebas de integración, usamos Selenium junto a Headless Chrome.

Para poder utilizarlo, instala el paquete chromium-chromedrive y asegúrate de que se encuentre enlazado en algún directorio que esté en la variable de entorno PATH:

```bash
sudo apt install chromium-chromedriver
sudo ln -s /usr/lib/chromium-browser/chromedriver /usr/local/bin/
```

¡Ya estás listo para [instalar Consul Democracy](local_installation.md)!
