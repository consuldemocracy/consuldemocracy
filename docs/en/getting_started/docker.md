# Using Docker for local development

You can use Docker to have a local CONSUL installation for development if:
- You're having troubles having [prerequisites](prerequisites) installed.
- You want to do a quick local installation just to try CONSUL or make a demo.
- You prefer not to interfer with other rails installations.

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

### macOS & Linux

Then lets create our secrets and database config files based on examples:

```bash
cp config/secrets.yml.example config/secrets.yml
cp config/database-docker.yml.example config/database.yml
```

Then you'll have to build the container with:
```bash
sudo docker build -t consul .
```

Create your app database images:

```bash
sudo docker-compose up -d database
```

Once built you can initialize your development DB and populate it with:
```
sudo docker-compose run app rake db:create
sudo docker-compose run app rake db:migrate
sudo docker-compose run app rake db:seed
sudo docker-compose run app rake db:dev_seed
```

### Windows

Pending to be completed... Contributions Welcome!

## Running local CONSUL with Docker

### macOS & Linux

Now we can finally run the application with:
```bash
sudo docker-compose up
```

And you'll be able to acces it at your browser visiting [http://localhost:3000](http://localhost:3000)

Additionally, if you want to run the rails console just run in another terminal:

```bash
sudo docker-compose run app rails console
```

To verify the containers are up execute **sudo docker ps .** You should see output similar to this:

![docker ps](https://i.imgur.com/ASvzXrd.png)

### Windows

Pending to be completed... Contributions Welcome!
