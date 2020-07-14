# Docker

You can use Docker to have a local CONSUL installation for development if:

* You're having troubles having [prerequisites](../local_installation/prerequisites.md) installed.
* You want to do a quick local installation just to try CONSUL or make a demo.
* You prefer not to interfer with other rails installations.

## Prerequisites

You should have installed Docker and Docker Compose in your machine:

### macOS

You can follow the [official docker install](https://docs.docker.com/docker-for-mac/install/)

Or if you have [homebrew](http://brew.sh) and [cask](https://caskroom.github.io/) installed you can just:

```bash
brew install docker
brew install docker-compose
brew cask install docker
open -a docker
```

You'll be asked to give Docker app permissions and type your password, then you're set.

### Linux

1. Install Docker:

   ```bash
   sudo apt-get update
   sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
   sudo apt-add-repository 'deb https://apt.dockerproject.org/repo ubuntu-xenial main'
   sudo apt-get update
   apt-cache policy docker-engine
   sudo apt-get install -y docker-engine
   ```

2. Install Docker Compose

   ```bash
   sudo curl -o /usr/local/bin/docker-compose -L "https://github.com/docker/compose/releases/download/1.15.0/docker-compose-$(uname -s)-$(uname -m)"
   sudo chmod +x /usr/local/bin/docker-compose
   ```

### Windows

Pending to be completed... Contributions Welcome!

## Installation

Clone the repo on your computer and enter the folder:

```bash
git clone git@github.com:consul/consul.git
cd consul
```

### macOS & Linux

Then lets create our secrets and database config files based on examples:

```bash
cp config/secrets.yml.example config/secrets.yml
cp config/database-docker.yml.example config/database.yml
```

Then you'll have to build the container with:

```bash
docker build -t consul .
```

Create your app database images:

```bash
docker-compose up -d database
```

Once built you can initialize your development DB and populate it with:

```text
docker-compose run app rake db:create
docker-compose run app rake db:migrate
docker-compose run app rake db:seed
docker-compose run app rake db:dev_seed
```

### Windows

Pending to be completed... Contributions Welcome!

## Running local CONSUL with Docker

### macOS & Linux

Now we can finally run the application with:

```bash
docker-compose up
```

And you'll be able to access it at your browser visiting [http://localhost:3000](http://localhost:3000)

Additionally, if you want to run the rails console just run in another terminal:

```bash
docker-compose run app rails console
```

To verify the containers are up execute:

```bash
docker ps .
```

You should see output similar to this: ![docker ps](https://i.imgur.com/ASvzXrd.png)

### Windows

Pending to be completed... Contributions Welcome!

## Having trouble?

Run these commands at **Consul's directory**, to erase all your previous Consul's Docker images and containers. Then restart the Docker [installation process](docker.md#installation):

1. Remove all CONSUL images:

   ```bash
   docker-compose down --rmi all -v --remove-orphans
   ```

2. Remove all CONSUL containers

   ```bash
   docker-compose rm -f -s -v
   ```

3. Verify if there is some container yet:

   ```bash
   docker ps -a
   ```

   Case positive, remove each one manually:

   ```bash
   docker container rm <container_id>
   ```

