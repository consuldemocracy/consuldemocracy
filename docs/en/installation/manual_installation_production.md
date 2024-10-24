# Manual installation for production

**WARNING:** This method is *not recommended* and not officially supported, since you should use the [installer](https://github.com/consuldemocracy/installer) instead. Use this method only if the installer isn't an option and you have experience configuring PostgreSQL, Puma or Passenger, NGINX, and SSL (with letsencrypt, for instance).

This guide assumes you've already [installed all the necessary packages](prerequisites.md) on your system. Make sure to install RVM to be able to install the Ruby version required by the project, which is defined in the .ruby-version file. Also, ensure you have installed FNM to install the Node.js version defined in the .node-version file.

The created directory structure herein is to be used with [capistrano](https://capistranorb.com/documentation/getting-started/structure/).

## Folder structure

First, create the main folder, clone the repo to a repo directory, and create the needed folders:

```bash
mkdir consul
cd consul
git clone --mirror https://github.com/consuldemocracy/consuldemocracy.git repo
mkdir releases shared
mkdir shared/log shared/tmp shared/config shared/public shared/storage
mkdir -p shared/public/assets shared/public/system shared/public/ckeditor_assets shared/public/machine_learning/data
```

## Initial release

Extract from the repo the first release to the respective directory, and create the symbolic link of the current release. Be sure to replace `<latest_consuldemocracy_stable_version>` with the number of the latest stable version of Consul Democracy, such as 2.1.1 or 2.2.0. To find the most recent version, visit the releases section in the [Consul Democracy repository](https://github.com/consuldemocracy/consuldemocracy/releases)

```bash
mkdir releases/first
cd repo
git archive <latest_consuldemocracy_stable_version> | tar -x -f - -C ../releases/first
cd ..
ln -s releases/first current
```

## Installing dependencies

Install the dependencies for Consul Democracy:

```bash
cd releases/first
bundle install --path ../../shared/bundle --without development test
fnm exec npm install
cd ../..
```

## Configuration files

Generate the `database.yml` and `secrets.yml` files:

```bash
cp current/config/secrets.yml.example shared/config/secrets.yml
cp current/config/database.yml.example shared/config/database.yml
cd releases/first/config
ln -s ../../../shared/config/database.yml
ln -s ../../../shared/config/secrets.yml
cd ../../..
```

Edit the `shared/config/database.yml` file, filling in `username` and `password` with the data generated during the [PostgreSQL setup](debian.md#postgresql).

We now need to generate a secret key:

```bash
cd current
bin/rake secret RAILS_ENV=production
cd ..
```

Copy that generated key, and edit the `shared/config/secrets.yml` file; under the section `production`, change the following data:

```yaml
  secret_key_base: enter_the_secret_key_you_have_just_generated
  server_name: enter_your_domain
```

If you aren't using a SSL certificate, replace the line saying `force_ssl: true` with `force_ssl: false`.

## Database setup

Create a database, load the seeds and compile the assets:

```bash
 cd current
 bin/rake db:create RAILS_ENV=production
 bin/rake db:migrate RAILS_ENV=production
 bin/rake db:seed RAILS_ENV=production
 bin/rake assets:precompile RAILS_ENV=production
```

## Starting the application

And, finally, start the Rails server:

```bash
bin/rails s -e production
```

Congratulations! Your server is now running in the production environment :smile:.
