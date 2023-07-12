# Usando Docker para desarrollo en local

Puedes usar Docker para tener una instalación local de Consul Democracy si:

- Estás teniendo problemas para instalar los [prerrequisitos](prerequisites.md) correctamente.
- Quieres tener una instalación local rápidamente para probar o hacer una demo.
- Prefieres no interferir con instalaciones de apps Rails existentes.

## Prerrequisitos

Debes tener instalador Docker y Docker Compose en tu ordenador:

### macOS

Puedes seguir la [guía oficial de docker](https://docs.docker.com/docker-for-mac/install/)

O si tienes instalado [homebrew](http://brew.sh) y [cask](https://caskroom.github.io/) puedes ejecutar:

```bash
brew install docker
brew install docker-compose
brew cask install docker
open -a docker
```

La aplicación de Docker te pedirá darle permisos e intrudocir tu contraseña.

### Linux

1. Instala Docker:

```bash
sudo apt-get update
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
sudo apt-get update
apt-cache policy docker-engine
sudo apt-get install -y docker-engine
```

2. Instala Docker Compose

```bash
sudo curl -o /usr/local/bin/docker-compose -L "https://github.com/docker/compose/releases/download/1.15.0/docker-compose-$(uname -s)-$(uname -m)"
sudo chmod +x /usr/local/bin/docker-compose
```

### Windows

En la página de [https://www.docker.com/get-started](Empezando con Docker), en la sección "Docker Desktop", selecciona "Download for Windows", y ejecútalo. Debería tardar unos 5 minutos.

Si encuentras el error "WSL 2 installation incomplete":

1. Ejecuta PowerShell como administrator
1. Ejecuta `dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart`
1. Ejecuta `dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart`
1. Instala el [paquete de actualización de WSL2 para 64 bits](https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi)
1. Ejecuta `wsl --set-default-version 2`
1. Reinicia el sistema
1. Se iniciará Docker Enginer. tardará unos minutos. Tras esto, tendrás la opción de usar la applicación de Docker Desktop y la orden `docker` de PowerShell/Bash

## Instalación

Clona el repositorio en tu ordenador y entra en el directorio:

```bash
git clone https://github.com/consuldemocracy/consuldemocracy.git
cd consuldemocracy
```

### macOS & Linux

Creamos nuestros ficheros de secrets y database basados en los ejemplos:

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

```
POSTGRES_PASSWORD=password docker-compose run app rake db:create db:migrate
POSTGRES_PASSWORD=password docker-compose run app rake db:dev_seed
```

### Windows

Pendiente de ser completado... ¡Se agradecen las Contribuciones!

## Corriendo Consul Democracy en local con Docker

### macOS & Linux

Una vez instalado, puedes lanzar la aplicación con:

```bash
POSTGRES_PASSWORD=password docker-compose up
```

Y podrás acceder a la aplicación desde tu navegador visitando [http://localhost:3000](http://localhost:3000)

Adicionalmente, si quieres lanzar por ejemplo la consola de rails:

```bash
POSTGRES_PASSWORD=password docker-compose run app rails console
```

Para verificar que los contenedores estan corriendo usa:

```bash
docker ps .
```

Deberías obtener algo similar a:
![docker ps](https://i.imgur.com/ASvzXrd.png)

### Windows

Pendiente de ser completado... ¡Se agradecen las Contribuciones!

## ¿Tienes problemas?

Ejecute los comandos en el **directorio de Consul Democracy**, para borrar todas las imágenes y contenedores anteriores del Docker de Consul Democracy. Luego, reinicie el [proceso de instalación](#instalacion) de Docker:

1. Quitar todas las imágenes de Consul Democracy:

```bash
docker-compose down --rmi all -v --remove-orphans
```

2. Quitar todos los contenedores de Consul Democracy

```bash
docker-compose rm -f -s -v
```

3. Verificar si todavía hay algún contenedor:

```bash
docker ps -a
```

Caso positivo, eliminar cada uno de forma manual:

```bash
docker container rm <container_id>
```
