# Using Docker for local development

## Prerequisites

Docker and Docker Compose should be installed on your machine. The installation process depends on your operating system.

### macOS

You can follow the [official Docker installation documentation](https://docs.docker.com/docker-for-mac/install/).

Or, if you have [homebrew](http://brew.sh) installed, you can just:

```bash
brew install docker
brew install docker-compose
brew install --cask docker
open -a docker
```

You'll be asked to give permissions to the Docker app and type your password; then, you're set.

### Linux

1. Install Docker and Docker Compose. For example, in Ubuntu 22.04:

```bash
sudo apt-get install docker.io docker-compose-v2
```

### Windows

The official Docker documentation includes a page with instructions to [install Docker Desktop on Windows](https://docs.docker.com/desktop/install/windows-install/). From there, download Docker Desktop for Windows and execute it.

## Installation

Clone the repo on your computer and enter the folder:

```bash
git clone https://github.com/consuldemocracy/consuldemocracy.git
cd consuldemocracy
```

Then create the secrets and database config files based on the example files:

```bash
cp config/secrets.yml.example config/secrets.yml
cp config/database.yml.example config/database.yml
```

Then build the image with:

```bash
POSTGRES_PASSWORD=password docker-compose build
```

And create the containers:

```bash
POSTGRES_PASSWORD=password docker-compose create
```

You can now initialize your development DB and populate it with:

```bash
POSTGRES_PASSWORD=password docker-compose run app rake db:create db:migrate
POSTGRES_PASSWORD=password docker-compose run app rake db:dev_seed
```

## Running Consul Democracy in development with Docker

Now we can finally run the application with:

```bash
POSTGRES_PASSWORD=password docker-compose up
```

And you'll be able to access it by opening your browser and visiting [http://localhost:3000](http://localhost:3000).

Additionally, if you'd like to run the rails console:

```bash
POSTGRES_PASSWORD=password docker-compose run app rails console
```

To verify the containers are up execute:

```bash
docker ps
```

You should see an output similar to this:

```bash
CONTAINER ID   IMAGE                 COMMAND                  CREATED          STATUS          PORTS      NAMES
603ec83b78a6   consuldemocracy-app   "./docker-entrypoint…"   23 seconds ago   Up 22 seconds              consuldemocracy-app-run-afb6d68e2d99
d57fdd9637d6   postgres:14.19        "docker-entrypoint.s…"   50 minutes ago   Up 22 seconds   5432/tcp   consuldemocracy-database-1
```

## Running tests with RSpec

Consul Democracy includes more than 6000 tests checking the way the application behaves. While we recommend you [configure your fork](../getting_started/configuration.md) to use a continuous integration system to run the whole test suite and verify that the latest changes don't break anything, while developing you probably want to run the tests related to the code you're working on.

First, setup the database for the test environment:

```bash
POSTGRES_PASSWORD=password docker-compose run app bundle exec rake db:test:prepare
```

Then you can run tests using RSpec. For example, to run the tests for the proposal model:

```bash
POSTGRES_PASSWORD=password docker-compose run app bundle exec rspec spec/models/proposal_spec.rb
```

System tests also work out of the box, although they might fail the first time while the tool running the tests downloads the right version of Chromedriver (which is needed to run them), and only "headless" mode (with a browser running in the background) is supported, which is the mode you'd probably use more than 95% of the time anyway. For example, to run the tests for the homepage:

```bash
POSTGRES_PASSWORD=password docker-compose run app bundle exec rspec spec/system/welcome_spec.rb
```

## Troubleshooting

Run these commands **inside Consul Democracy's directory**, to erase all your previous Consul Democracy's Docker images and containers. Then start the Docker [installation process](#installation) once again.

1. Remove all Consul Democracy images:

```bash
docker-compose down --rmi all -v --remove-orphans
```

2. Remove all Consul Democracy containers:

```bash
docker-compose rm -f -s -v
```

3. Check whether there are still containers left:

```bash
docker ps -a
```

4. In case there are, remove each one manually:

```bash
docker container rm <container_id>
```
