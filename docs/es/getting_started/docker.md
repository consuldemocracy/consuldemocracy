# Usando Docker para desarrollo en local

Puedes usar Docker para tener una instalación local de CONSUL si:
- Estás teniendo problemas para instalar los [prerrequisitos](prerequisites) correctamente.
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

Pendiente de ser completado... ¡Se agradecen las Contribuciones!

## Instalación

### macOS & Linux
Creamos nuestros ficheros de secrets y database basados en los ejemplos:
```bash
cp config/secrets.yml.example config/secrets.yml
cp config/database-docker.yml.example config/database.yml
```

Y generamos el contenedor:
```bash
sudo docker build -t consul .
```

Creamos las imágenes de base de datos:
```bash
sudo docker-compose up -d database
```

Y la inicializamos con:
```
sudo docker-compose run app rake db:create
sudo docker-compose run app rake db:migrate
sudo docker-compose run app rake db:seed
sudo docker-compose run app rake db:dev_seed
```

### Windows

Pendiente de ser completado... ¡Se agradecen las Contribuciones!

## Corriendo CONSUL en local con Docker

### macOS & Linux

Una vez instalado, puedes lanzar la aplicación con:
```bash
sudo docker-compose up
```

Y podrás acceder a la aplicación desde tu navegador visitando [http://localhost:3000](http://localhost:3000)

Adicionalmente, si quieres lanzar por ejemplo la consola de rails:

```bash
sudo docker-compose run app rails console
```

Para verificar que los contenedores estan corriendo usa:
`sudo docker ps .`

Deberías obtener algo similar a:

![docker ps](https://i.imgur.com/ASvzXrd.png)

### Windows

Pendiente de ser completado... ¡Se agradecen las Contribuciones!
