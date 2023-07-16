# Configuration for development and test environments (Ubuntu 18.04)

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
sudo apt install libssl-dev autoconf bison build-essential libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm5 libgdbm-dev
```

The next step is installing a Ruby version manager, like rbenv:

```bash
wget -q https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer -O- | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
```

## Node.js

To compile the assets, you'll need a JavaScript runtime. Node.js is the preferred option.

Run the following command on your terminal:

```bash
sudo apt install nodejs
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

To make sure the UTF-8 enconding is used, create a file:

```
sudo nano /etc/profile.d/lang.sh
```

Add the following:

```
export LANGUAGE="en_US.UTF-8"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
```

Reconfigure Postgres to use the UTF-8 encoding:

`````
sudo su - postgres
psql

update pg_database set datistemplate=false where datname='template1';
drop database Template1;
create database template1 with owner=postgres encoding='UTF-8'
lc_collate='en_US.utf8' lc_ctype='en_US.utf8' template template0;
update pg_database set datistemplate=true where datname='template1';

\q
exit
`````

## Imagemagick

Install Imagemagick:

```bash
sudo apt install imagemagick
```

## ChromeDriver

To run E2E integration tests, we use Selenium along with Headless Chrome.

To get it working, install the chromium-chromedriver package and make sure it's available on your shell's PATH:

```bash
sudo apt install chromium-chromedriver
sudo ln -s /usr/lib/chromium-browser/chromedriver /usr/local/bin/
```

Now you're ready to go [get Consul Democracy installed](local_installation.md)!
