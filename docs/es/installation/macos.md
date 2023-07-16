# Configuración para los entornos de desarrollo y pruebas (Mac OS X)

## Homebrew

Homebrew es un gestor de paquetes para OS X muy popular. Es recomendable usarlo pues facilita enormemente la instalación de algunos de los paquetes necesarios.

Puedes encontrar las instrucciones de instalación en: [brew.sh](http://brew.sh)

## XCode y XCode Command Line Tools

Para utilizar git necesitarás instalar *Xcode* (está en la Mac App Store) y las *Xcode Command Line Tools* (se instalan desde el menú de Xcode).

## Git y Github

Puedes descargar git desde: [git-scm.com/download/mac](https://git-scm.com/download/mac)

## Gestor de versiones de Ruby

OS X ya viene con una versión preinstalada de ruby, pero es bastante vieja y en nuestro caso no nos sirve. Una de las formas de instalar Ruby es a través de rbenv. Las instrucciones de instalación están en su GitHub y son bastante claras:

[github.com/rbenv/rbenv](https://github.com/rbenv/rbenv)

## Bundler

```
gem install bundler
```

## Node.js

Para compilar los archivos estáticos (JS, CSS, imágenes, etc.), es necesario un _runtime_ de JavaScript. OS X viene con un _runtime_ integrado llamado `Apple JavaScriptCore` pero Node.js es la opción recomendada.

Para instalar Node, puedes usar [n](https://github.com/tj/n)

Ejecuta el siguiente comando en tu terminal:

```
curl -L https://git.io/n-install | bash -s -- -y lts
```

Y este instalará automáticamente la versión LTS (_Long Term Support_, inglés para "Soporte a largo plazo") más reciente de Node en tu directorio `$HOME` (Este comando hace uso de [n-install](https://github.com/mklement0/n-install))

## PostgreSQL (>=9.4)

```
brew install postgres
```

Una vez instalado es necesario *inicializar* la instalación:

```
initdb /usr/local/var/postgres
```

Ahora vamos a configurar algunos aspectos del usuario por defecto. Primero iniciamos el servidor de postgres con:

```
postgres -D /usr/local/var/postgres
```

Llegados a este punto se supone que tenemos postgres correctamente instalado y se nos habrá creado un usuario por defecto (cuyo nombre es nuestro nombre de usuario), y que (todavía) no tiene contraseña.

Si ejecutamos `psql` accederemos a la consola de postgres con el usuario por defecto. Probablemente fallará porque es necesario que de antemano exista una base de datos por defecto para dicho usuario. Podemos crearla ejecutando sobre la terminal:

```
createdb 'tu_nombre_de_usuario'
```

Si ahora ejecutamos `psql` de nuevo deberíamos poder acceder correctamente a la consola de postgres. Si sobre la consola de postgres ejecutas `\du` puede ver la lista de usuarios actual.

En el caso de que quieras asignarte una contraseña puedes hacerlo desde la consola de postgres con:

```
ALTER USER tu_nombre_usuario WITH PASSWORD 'tu_contraseña';
```

Ahora vamos a crear el usuario *consul*, que es el que utiliza la aplicación. Ejecuta sobre la consola de postgres:

```
CREATE ROLE consul WITH PASSWORD '000';
ALTER ROLE consul WITH SUPERUSER;
ALTER ROLE consul WITH login;
```

Si en algún momento durante la instalación de PostgreSQL y sospechas que te has equivocado y deseas desinstalarlo y volver a empezar desde cero:

```
brew uninstall postgres
```

También tendrás que borrar el siguiente directorio para que no de conflictos cuando intentes volver a instalarlo (fuente: [gist.github.com/lxneng/741932](https://gist.github.com/lxneng/741932)):

```
rm -rf /usr/local/var/postgres
```

## ChromeDriver

```
brew install chromedriver
```

## Imagemagick

```
brew install imagemagick
```

Ahora que ya tenemos todas las dependencias instalado podemos proceder con la [instalación de Consul Democracy](local_installation.md)
