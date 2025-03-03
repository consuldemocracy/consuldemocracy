# Configuración para los entornos de desarrollo y pruebas (Ubuntu 24.04)

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
sudo apt install libssl-dev autoconf bison build-essential libyaml-dev libreadline-dev zlib1g-dev libncurses-dev libffi-dev libgdbm-dev
```

A continuación instalaremos un gestor de versiones de Ruby, como rbenv:

```bash
wget -qO- https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-installer | bash
source ~/.bashrc
```

## CMake y pkg-config

Para compilar algunas de las dependencias del proyecto, necesitamos CMake y pkg-config:

```bash
sudo apt install cmake pkg-config
```

## Gestor de versiones de Node.js

Para compilar los archivos estáticos (JS, CSS, imágenes, etc.), es necesario un _runtime_ de JavaScript. Node.js es la opción recomendada. Para instalar Node.js, instalaremos un gestor de versiones de Node.js, como NVM:

```bash
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.bashrc
```

## PostgreSQL

Instala postgresql y sus dependencias de desarrollo con:

```bash
sudo apt install postgresql libpq-dev
```

Para el correcto funcionamiento de Consul Democracy, necesitas configurar un usuario para tu base de datos. Como ejemplo, crearemos un usuario llamado "consul":

```bash
sudo -u postgres createuser consul --createdb --superuser --pwprompt
```

## Imagemagick

Instala Imagemagick:

```bash
sudo apt install imagemagick
```

## Chrome o Chromium

Para poder ejecutar los tests de sistema, necesitaremos tener instalado Chrome o Chromium.

```bash
sudo apt install chromium-browser
```

¡Ya estás listo para [instalar Consul Democracy](local_installation.md)!
