# Configuration for development and test environments (macOS Sonoma 14.6)

## Homebrew

Homebrew is a very popular package manager for macOS. It's advised to use it since it makes the installation of some of the dependencies much easier.

You can find the installation instructions at: [brew.sh](http://brew.sh)

## Git

You can install git:

```bash
brew install git
```

## Ruby version manager

macOS already comes with a preinstalled Ruby version, but it's quite old and we need a newer one. One of the multiple ways of installing Ruby in macOS is through [rbenv](https://github.com/rbenv/rbenv):

```bash
brew install rbenv
rbenv init
source ~/.zprofile
```

## CMake and pkg-config

In order to compile some of the project dependencies, we need CMake and pkg-config:

```bash
brew install cmake pkg-config
```

## Node.js version manager

To compile the assets, you'll need a JavaScript runtime. macOS comes with an integrated runtime called `Apple JavaScriptCore` but Node.js is the preferred option. To install Node.js, we will install a Node.js version manager, like NVM:

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.zprofile
```

## PostgreSQL

```bash
brew install postgresql
```

Now we're going to configure some things related to the *default user*. First we start postgres server with:

```bash
brew services start postgresql
```

At this point we're supposed to have postgres correctly installed and a default user will automatically be created (whose name will match our username). This user hasn't got a password yet.

If we run `psql` we'll login into the postgres console with the default user. It will probably fail since it's required that a default database exists for that user. We can create it by typing:

```bash
createdb 'your_username'
```

If we run `psql` again we should now get access to postgres console. With `\du` you can see the current users list.

In case you want to set a password for your user you can make it through the postgres console by:

```sql
ALTER USER your_username WITH PASSWORD 'your_password';
```

## Imagemagick

Install Imagemagick:

```bash
brew install imagemagick
```

## Chrome or Chromium

In order to run the system tests, we need to install Chrome or Chromium.

```bash
brew install google-chrome
```

Now you're ready to go [get Consul Democracy installed](local_installation.md)!
