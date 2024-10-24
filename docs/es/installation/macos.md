# Configuración para los entornos de desarrollo y pruebas (macOS Sonoma 14.6)

## Homebrew

Homebrew es un gestor de paquetes para macOS muy popular. Es recomendable usarlo pues facilita enormemente la instalación de algunos de los paquetes necesarios.

Puedes encontrar las instrucciones de instalación en: [brew.sh](http://brew.sh)

## Git

Puedes instalar git:

```bash
brew install git
```

## Gestor de versiones de Ruby

macOS ya viene con una versión preinstalada de ruby, pero necesitamos una versión más reciente. Una de las formas de instalar Ruby es a través de un gestor de versiones de Ruby como [rbenv](https://github.com/rbenv/rbenv):

```bash
brew install rbenv
rbenv init
source ~/.zprofile
```

## CMake y pkg-config

Para compilar algunas de las dependencias del proyecto, necesitamos CMake y pkg-config:

```bash
brew install cmake pkg-config
```

## Gestor de versiones de Node.js

Para compilar los archivos estáticos (JS, CSS, imágenes, etc.), es necesario un _runtime_ de JavaScript. macOS viene con un _runtime_ integrado llamado `Apple JavaScriptCore` pero Node.js es la opción recomendada. Para instalar Node.js, instalaremos un gestor de versiones de Node.js, como NVM:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.zprofile
```

## PostgreSQL

```bash
brew install postgresql
```

Ahora vamos a configurar algunos aspectos del usuario por defecto. Primero iniciamos el servidor de postgres con:

```bash
brew services start postgresql
```

Llegados a este punto se supone que tenemos postgres correctamente instalado y se nos habrá creado un usuario por defecto (cuyo nombre es nuestro nombre de usuario), y que (todavía) no tiene contraseña.

Si ejecutamos `psql` accederemos a la consola de postgres con el usuario por defecto. Probablemente fallará porque es necesario que de antemano exista una base de datos por defecto para dicho usuario. Podemos crearla ejecutando sobre la terminal:

```bash
createdb 'tu_nombre_de_usuario'
```

Si ahora ejecutamos `psql` de nuevo deberíamos poder acceder correctamente a la consola de postgres. Si sobre la consola de postgres ejecutas `\du` puedes ver la lista de usuarios actual.

En el caso de que quieras asignarte una contraseña puedes hacerlo desde la consola de postgres con:

```sql
ALTER USER tu_nombre_usuario WITH PASSWORD 'tu_contraseña';
```

## Imagemagick

Instala Imagemagick:

```bash
brew install imagemagick
```

## Chrome o Chromium

Para poder ejecutar los tests de sistema, necesitaremos tener instalado Chrome o Chromium.

```bash
brew install google-chrome
```

¡Ya estás listo para [instalar Consul Democracy](local_installation.md)!
