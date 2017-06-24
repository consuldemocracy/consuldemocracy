# Configuration for development and test environments (GNU/Linux)

## Git

Git is officially maintained in Debian/Ubuntu:

```
sudo apt-get install git
```

## Ruby

Ruby versions packaged in official repositories are not suitable to work with consul (at least Debian 7 and 8), so we'll have to install it manually.

The preferred method is via rvm:

(only the multi user option installs all dependencies automatically, as we use 'sudo'.)

### As local user

```
curl -L https://get.rvm.io | bash -s stable
```

### For all system users

```
curl -L https://get.rvm.io | sudo bash -s stable
```

and then add your user to rvm group

```
sudo usermod -a -G rvm <user>
```

and finally, add rvm script source to user's bash (~/.bashrc) (this step it's only necessary if you still can't execute rvm command)

```
[[ -s /usr/local/rvm/scripts/rvm ]] && source /usr/local/rvm/scripts/rvm
```

with all this, you are suppose to be able to install a ruby version from rvm, as for example version 2.3.0:

```
sudo rvm install 2.3.0
```

## Bundler

with

```
gem install bundler
```

or there is more methods [here](https://rvm.io/integration/bundler) that should be better as:

```
gem install rubygems-bundler
```

## PostgreSQL (>=9.4)

PostgreSQL version 9.4 is not official in debian 7 (wheezy), in 8 it seems to be officially maintained.

So you have to add a repository, the official postgresql works fine.

Add the repository to apt, for example creating file */etc/apt/sources.list.d/pgdg.list* with:

```
deb http://apt.postgresql.org/pub/repos/apt/ wheezy-pgdg main
```

afterwards you'll have to download the key, and install it, by:

```
wget https://www.postgresql.org/media/keys/ACCC4CF8.asc
apt-key add ACCC4CF8.asc
```

and install postgresql

```
apt-get update
apt-get install postgresql-9.4
```

## Ghostscript

```
apt-get install ghostscript
```

## Cloning the repository

Now, with all the dependencies installed, clone the Consul repository:

```
git clone https://github.com/consul/consul.git
cd consul
bundle install
cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml
```

Perhaps it's needed to create a superuser rol with password in postgresql, and write it in */config/database.yml* 'user:' and 'password:' fields.

Also, it seems that postgresql use as default an unix socket for localhost communications. If we encounter problems creating database (connection problems) we can change in */config/database.yml* the line:

```
host: localhost
```

for:

```
host: /var/run/postgresql
```

After this:

```
rake db:create
rake db:setup
rake db:dev_seed
RAILS_ENV=test bin/rake db:setup
```
