# Configuración para los entornos de desarrollo y pruebas (Debian 9.8)

## Super usuario

El programa 'sudo' no viene instalado en Debian por defecto. Su instalación y configuración es posible, se puede encontrar informacion al respecto [aquí](https://wiki.debian.org/es/sudo). Pero no lo recomendamos porque puede causar otros problemas. Recomendamos que se ejecuten las siguientes instrucciones como un super usuario, así que asegúrate de que la primera instrucción que ejecutes sea:

```
su
```

## Git

Git es mantenido oficialmente en Debian:

```
apt-get install git
```

## Curl

Curl es mantenido oficialmente en Debian:

```
apt-get install curl
```

## Ruby

Las versiones de Ruby versions empaquetadas en repositorios oficiales no son aptas para trabajar con consul (al menos Debian 7 y 8), así que debemos instalar manualmente.

El método recomendado es via rvm:

### Como usuario local

```
command curl -sSL https://rvm.io/mpapis.asc | gpg --import -
command curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
curl -L https://get.rvm.io | bash -s stable
```

despues añadimos el script rvm a nuestro bash (~/.bashrc) (este paso sólo es necesario si no puedes ejecutar el comando rvm)

```
[[ -s /usr/local/rvm/scripts/rvm ]] && source /usr/local/rvm/scripts/rvm
```

por úlitmo, volvemos a cargar el .bashrc para poder ejecutar RVM

```
source /root/.bashrc
```

con todo esto, deberías poder instalar la versión de ruby con rvm, por ejemplo la 2.3.2:

```
rvm install 2.3.2
```

## Bundler

lo instalammos usando

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

vuelve a cargar el .bashrc para poder ejecutar node

```
source /root/.bashrc
```

Comprueba que está correctamente instalado ejecutando:

```
node -v
```

## PostgreSQL (>=9.4)

La versión 9.4 de PostgreSQL no es oficial en Debian 9.

Así que debemos añadir el respositorio oficial de postgresql a apt, por ejemplo creando el fichero */etc/apt/sources.list.d/pgdg.list* con:

```
deb http://security.debian.org/debian-security jessie/updates main
```

después deberás descargar la key e instalarla:

```
wget https://www.postgresql.org/media/keys/ACCC4CF8.asc
apt-key add ACCC4CF8.asc
```

y finalmente instalar postgresql

```
apt-get update
apt-get install postgresql-9.4 postgresql-server-dev-9.4 postgresql-contrib-9.4
```

Para el correcto funcionamiento de CONSUL, necesitas confgurar un usuario para tu base de datos. Como ejemplo, crearemos un usuario llamado "consul":

```
su - postgres

createuser consul --createdb --superuser --pwprompt

exit
```

## ChromeDriver

Para realizar pruebas de integración, usamos Selenium junto a Headless Chrome.

Para ello, primero instala el siguiente paquete:

```bash
apt-get install chromedriver
ln -s /usr/lib/chromedriver /usr/local/bin/
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
