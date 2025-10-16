# Usando Docker para desarrollo en local

## Prerrequisitos

Debes tener instalados Docker y Docker Compose en tu ordenador. El proceso de instalación depende de tu sistema operativo.

### macOS

Puedes seguir la [guía oficial de Docker](https://docs.docker.com/docker-for-mac/install/).

O, si tienes instalado [homebrew](http://brew.sh), puedes ejecutar:

```bash
brew install docker
brew install docker-compose
brew install --cask docker
open -a docker
```

La aplicación de Docker te pedirá darle permisos e introducir tu contraseña.

### Linux

1. Instala Docker y Docker Compose. Por ejemplo, en Ubuntu 22.04:

```bash
sudo apt-get install docker.io docker-compose-v2
```

### Windows

La documentación oficial de Docker incluye una página con instrucciones para [instalar Docker Desktop en Windows](https://docs.docker.com/desktop/install/windows-install/). En esa página, descarga Docker Desktop para Windows y ejecútalo.

<h2 id="instalacion">Instalación</h2>

Clona el repositorio en tu ordenador y entra en el directorio:

```bash
git clone https://github.com/consuldemocracy/consuldemocracy.git
cd consuldemocracy
```

A continuación, crea los ficheros de `config/secrets.yml` y `config/database.yml` basados en los ficheros de ejemplo:

```bash
cp config/secrets.yml.example config/secrets.yml
cp config/database.yml.example config/database.yml
```

Ahora genera la imagen con:

```bash
POSTGRES_PASSWORD=password docker-compose build
```

Y crea los contenedores:

```bash
POSTGRES_PASSWORD=password docker-compose create
```

Por último, crea la base de datos e introduce datos de prueba:

```bash
POSTGRES_PASSWORD=password docker-compose run app rake db:create db:migrate
POSTGRES_PASSWORD=password docker-compose run app rake db:dev_seed
```

## Arranque de Consul Democracy en desarrollo

Una vez instalada, puedes lanzar la aplicación con:

```bash
POSTGRES_PASSWORD=password docker-compose up
```

Y podrás acceder a la aplicación desde tu navegador visitando [http://localhost:3000](http://localhost:3000).

Adicionalmente, si quieres lanzar por ejemplo la consola de rails:

```bash
POSTGRES_PASSWORD=password docker-compose run app rails console
```

Para verificar que los contenedores están ejecutándose usa:

```bash
docker ps
```

Deberías obtener algo similar a:

```bash
CONTAINER ID   IMAGE                 COMMAND                  CREATED          STATUS          PORTS      NAMES
603ec83b78a6   consuldemocracy-app   "./docker-entrypoint…"   23 seconds ago   Up 22 seconds              consuldemocracy-app-run-afb6d68e2d99
d57fdd9637d6   postgres:14.19        "docker-entrypoint.s…"   50 minutes ago   Up 22 seconds   5432/tcp   consuldemocracy-database-1
```

## Ejecutar tests con RSpec

Consul Democracy incluye más de 6000 tests que comprueban la manera en que se comporta la aplicación. Si bien recomendamos que [configures tu "fork"](../getting_started/configuration.md) para que use un sistema de integración continua para ejecutar todos los tests y comprobar que los últimos cambios no rompen nada, durante el desarrollo probablemente quieras ejecutar tests relacionados con el código en el que estás trabajando.

En primer lugar, prepara la base de datos para el entorno de test:

```bash
POSTGRES_PASSWORD=password docker-compose run app bundle exec rake db:test:prepare
```

Ahora puedes ejecutar tests usando RSpec. Por ejemplo, para ejecutar los tests del modelo "proposal":

```bash
POSTGRES_PASSWORD=password docker-compose run app bundle exec rspec spec/models/proposal_spec.rb
```

Los tests de sistema también funcionan sin que tengas que realizar ninguna configuración adicional, si bien la primera vez que se ejecutan pueden fallar mientras la herramienta que ejecuta los tests descarga una versión adecuada de Chromedriver (que se necesita para ejecutarlos), y solamente puedes ejecutar el modo "headless" (con un navegador ejecutándose en segundo plano), que por otro lado en cualquier caso es el modo que utilizarías más del 95% del tiempo. Por ejemplo, para ejecutar los tests de la página de inicio:

```bash
POSTGRES_PASSWORD=password docker-compose run app bundle exec rspec spec/system/welcome_spec.rb
```

## Resolución de problemas

Ejecuta los siguientes comandos **en el directorio de Consul Democracy** para borrar todas las imágenes y contenedores anteriores del Docker de Consul Democracy. Luego, comienza de nuevo con el [proceso de instalación](#instalacion) de Docker.

1. Quita todas las imágenes de Consul Democracy:

```bash
docker-compose down --rmi all -v --remove-orphans
```

2. Quita todos los contenedores de Consul Democracy:

```bash
docker-compose rm -f -s -v
```

3. Verifica si todavía hay algún contenedor:

```bash
docker ps -a
```

4. En caso afirmativo, elimina cada uno de forma manual:

```bash
docker container rm <container_id>
```
