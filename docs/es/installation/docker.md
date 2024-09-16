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
cp config/database-docker.yml.example config/database.yml
```

Y generamos el contenedor:

```bash
POSTGRES_PASSWORD=password docker-compose build
```

Arrancamos el servicio de base de datos:

```bash
POSTGRES_PASSWORD=password docker-compose up -d database
```

Ahora podemos crear la base de datos e introducir datos de prueba:

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
![docker ps](https://i.imgur.com/ASvzXrd.png)

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
