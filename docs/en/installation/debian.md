# Configuration for development and test environments (Debian GNU/Linux 9.8)

## Superuser

Note that 'sudo' is not installed by default in Debian. It's possible to install and configure it, you can find information [here](https://wiki.debian.org/sudo). But  we don't recommend it cause you may have other problems. We recommend running the following commands as a superuser, so make sure the very first command you run is:

```
su
```

> For [Vagrant](/en/installation/vagrant.md) run:
> ```
> sudo su -
> ```

## System update

Run a general system update:

```bash
apt-get update
```

## Git

Git is officially maintained in Debian:

```
apt-get install git
```

## Curl

Curl is officially maintained in Debian:

```
apt-get install curl
```

## Ruby version manager

Ruby versions packaged in official repositories are not suitable to work with consul, so we'll have to install it manually.

One possible tool is rvm:

### As a local user

```
command curl -sSL https://rvm.io/mpapis.asc | gpg --import -
command curl -sSL https://rvm.io/pkuczynski.asc | gpg --import -
curl -L https://get.rvm.io | bash -s stable
```

then add rvm script source to user's bash (~/.bashrc) (this step is only necessary if you can't execute the rvm command)

```
[[ -s /usr/local/rvm/scripts/rvm ]] && source /usr/local/rvm/scripts/rvm
```

and finally, reload .bashrc to be able to run RVM

```
source ~/.bashrc
```

## Node.js

To compile the assets, you'll need a JavaScript runtime. Node.js is the preferred option. As with Ruby, we don't recommend installing Node from your distro's repositories.

To install it, you can use [n](https://github.com/tj/n)

Run the following command on your terminal:

```
curl -L https://git.io/n-install | bash -s -- -y lts
```

And it will install the latest LTS (Long Term Support) Node version on your `$HOME` folder automatically (This makes use of [n-install](https://github.com/mklement0/n-install))

Reload .bashrc to be able to run node

```
source /root/.bashrc
```

Check it's correctly installed by running:

```
node -v
```

## PostgreSQL (>=9.4)

PostgreSQL version 9.4 is not official in debian 9.

So you have to add a repository, the official postgresql works fine.

Add the repository to apt, for example creating file */etc/apt/sources.list.d/pgdg.list* with:

```
deb http://security.debian.org/debian-security jessie/updates main
```

afterwards you'll have to download the key, and install it, by:

```
wget https://www.postgresql.org/media/keys/ACCC4CF8.asc
apt-key add ACCC4CF8.asc
```

and install postgresql

```
apt-get update
apt-get install postgresql-9.4 postgresql-server-dev-9.4 postgresql-contrib-9.4
```

You also need to configure a user for your database. As an example, we'll choose the username "consul":

```
su - postgres

createuser consul --createdb --superuser --pwprompt

exit
```

## Imagemagick

Install Imagemagick:

```bash
apt-get install imagemagick
```

## ChromeDriver

To run E2E integration tests, we use Selenium along with Headless Chrome.

To get it working, install the chromedriver package:

```bash
apt-get install chromedriver
ln -s /usr/lib/chromedriver /usr/local/bin/
```

Make sure it's working as expected by running the following command:

```bash
chromedriver --version
```

You should receive an output with the latest version of ChromeDriver. If that's the case, you're good to go!

If you are using an Arch-based distro, installing `chromium` from the `extra` repository should be sufficient.

You also have the option of just installing ChromeDriver from AUR. If you use `pacaur`, run the following command:

```bash
pacaur -S chromedriver
```

Now you're ready to go get Consul [installed](local_installation.md)!!
