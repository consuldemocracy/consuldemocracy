# MacOS

## Homebrew

Homebrew is a very popular package manager for OS X. It's advised to use it since it makes the installation of some of the dependencies much easier.

You can find the installation instructions at: [brew.sh](http://brew.sh)

## XCode and XCode Command Line Tools

To install _git_ you'll first need to install _Xcode_ \(download it from the Mac App Store\) and its _Xcode Command Line Tools_ \(you can install them from the Xcode's app menu\)

## Git and Github

You can download git from: [git-scm.com/download/mac](https://git-scm.com/download/mac)

## Ruby version manager

OS X already comes with a preinstalled Ruby version, but it's quite old and we need a newer one. One of the multiple ways of installing Ruby in OS X is through _rbenv_. The installation instructions are in its GitHub repository and are pretty straight-forward:

[github.com/rbenv/rbenv](https://github.com/rbenv/rbenv)

## Node.js

To compile the assets, you'll need a JavaScript runtime. OS X comes with an integrated runtime called `Apple JavaScriptCore` but Node.js is the preferred option.

To install it, you can use [n](https://github.com/tj/n)

Run the following command on your terminal:

```text
curl -L https://git.io/n-install | bash -s -- -y lts
```

And it will install the latest LTS \(Long Term Support\) Node version on your `$HOME` folder automatically \(This makes use of [n-install](https://github.com/mklement0/n-install)\)

## PostgreSQL \(&gt;=9.4\)

```text
brew install postgres
```

Once installed, we need to _initialize_ it:

```text
initdb /usr/local/var/postgres
```

Now we're going to configure some things related to the _default user_. First we start postgres server with:

```text
postgres -D /usr/local/var/postgres
```

At this point we're supposed to have postgres correctly installed and a default user will automatically be created \(whose name will match our username\). This user hasn't got a password yet.

If we run `psql` we'll login into the postgres console with the default user. Probably it will fail since its required that a default database exists for that user. We can create it by typing:

```text
createdb 'your_username'
```

If we run `psql` again we should now get access to postgres console. With `\du` you can see the current users list.

In case you want to set a password for your user you can make it throught postgres console by:

```text
ALTER USER your_username WITH PASSWORD 'your_password';
```

Now we'll create the _consul_ user, the one the application is using. Run in postgres console:

```text
CREATE ROLE consul WITH PASSWORD '000';
ALTER ROLE consul WITH SUPERUSER;
ALTER ROLE consul WITH login;
```

If at any point during PostgreSQL installation you feel you have messed things up, you can uninstall it and start again by running:

```text
brew uninstall postgres
```

You'll have to delete also this directory \(otherwise the new installation will generate conflicts, source: [gist.github.com/lxneng/741932](https://gist.github.com/lxneng/741932)\):

```text
rm -rf /usr/local/var/postgres
```

## ChromeDriver

```text
brew install chromedriver
```

## Imagemagick

```text
brew install imagemagick
```

Now that we have all the dependencies installed we can go ahead and [install Consul](./).

