# Configuration for development and test environments (Mac OS X)

## Homebrew

Homebrew is a very popular package manager for OS X. It's advised to use it since it makes the installation of some of the dependencies much easier.

You can find the installation instructions at: [brew.sh](http://brew.sh)

## XCode and XCode Command Line Tools

To install *git* you'll first need to install *Xcode* (download it from the Mac App Store) and its *Xcode Command Line Tools* (you can install them from the Xcode's app menu)

## Git

You can download git from: [git-scm.com/download/mac](https://git-scm.com/download/mac)

## Ruby y rbenv

OS X already comes with a preinstalled Ruby version, but it's quite old and we need a newer one (2.3.2). One of the multiple ways of installing Ruby in OS X is through *rbenv*. The installation instructions are in its GitHub repository and are pretty straight-forward:

[github.com/rbenv/rbenv](https://github.com/rbenv/rbenv)

## Bundler

```
gem install bundler
```

## PostgreSQL (>=9.4)

```
brew install postgres
```

Once installed, we need to *initialize* it:

```
initdb /usr/local/var/postgres
```

Now we're going to configure some things related to the *default user*. First we start postgres server with:

```
postgres -D /usr/local/var/postgres
```

At this point we're supposed to have postgres correctly installed and a default user will automatically be created (whose name will match our username). This user hasn't got a password yet.

If we run `psql` we'll login into the postgres console with the default user. Probably it will fail since its required that a default database exists for that user. We can create it by typing:

```
createdb 'your_username'
```

If we run `psql` again we should now get access to postgres console. With `\du` you can see the current users list.

In case you want to set a password for your user you can make it throught postgres console by:

```
ALTER USER your_username WITH PASSWORD 'your_password';
```

Now we'll create the *consul* user, the one the application is using. Run in postgres console:

```
CREATE ROLE consul WITH PASSWORD '000';
ALTER ROLE consul WITH SUPERUSER;
ALTER ROLE consul WITH login;
```

If at any point during PostgreSQL installation you feel you have messed things up, you can uninstall it and start again by running:

```
brew uninstall postgres
```

You'll have to delete also this directory (otherwise the new installation will generate conflicts, source: [gist.github.com/lxneng/741932](https://gist.github.com/lxneng/741932)):

```
rm -rf /usr/local/var/postgres
```

## Postgis

```
brew install postgis
```

## Ghostscript

```
brew install ghostscript
```

## PhantomJS

```
brew install phantomjs
```

## Imagemagick

```
brew install imagemagick
```

## Cloning the repository

Now that we have all the dependencies installed we can download the repository:

```
git clone https://github.com/consul/consul.git
cd consul
bundle install
cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml
```

Now copy in `database.yml` the database user and password you used for *consul*.

After this:

```
rake db:create
rake db:setup
rake db:dev_seed
RAILS_ENV=test bin/rake db:setup
```

To run the tests:

```
bundle exec rspec
```
