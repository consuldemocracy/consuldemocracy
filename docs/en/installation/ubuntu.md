# Configuration for development and test environments (Ubuntu 24.04)

## System update

Run a general system update:

```bash
sudo apt update
```

## Git

Git is officially maintained in Ubuntu:

```bash
sudo apt install git
```

## Ruby version manager

Ruby versions packaged in official repositories are not suitable to work with Consul Democracy, so we'll have to install it manually.

First, we need to install Ruby's development dependencies:

```bash
sudo apt install libssl-dev autoconf bison build-essential libyaml-dev libreadline-dev zlib1g-dev libncurses-dev libffi-dev libgdbm-dev
```

The next step is installing a Ruby version manager, like rbenv:

```bash
wget -qO- https://github.com/rbenv/rbenv-installer/raw/main/bin/rbenv-installer | bash
source ~/.bashrc
```

## CMake and pkg-config

In order to compile some of the project dependencies, we need CMake and pkg-config:

```bash
sudo apt install cmake pkg-config
```

## Node.js version manager

To compile the assets, you'll need a JavaScript runtime. Node.js is the preferred option. To install Node.js, we will install a Node.js version manager, like NVM:

```bash
wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.bashrc
```

## PostgreSQL

Install postgresql and its development dependencies with:

```bash
sudo apt install postgresql libpq-dev
```

You also need to configure a user for your database. As an example, we'll choose the username "consul":

```bash
sudo -u postgres createuser consul --createdb --superuser --pwprompt
```

## Imagemagick

Install Imagemagick:

```bash
sudo apt install imagemagick
```

## Chrome or Chromium

In order to run the system tests, we need to install Chrome or Chromium.

```bash
sudo apt install chromium-browser
```

Now you're ready to go [get Consul Democracy installed](local_installation.md)!
