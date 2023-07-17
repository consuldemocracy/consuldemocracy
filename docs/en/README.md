![CONSUL DEMOCRACY logo](../img/consul_logo.png)

# CONSUL DEMOCRACY

Citizen Participation and Open Government Application

## CONSUL DEMOCRACY Project main website

You can access the main website of the project at [http://consuldemocracy.org](http://consuldemocracy.org) where you can find documentation about the use of the platform, videos, and links to the community space.

## Configuration for development and test environments

**NOTE**: For more detailed instructions check the [docs](https://docs.consuldemocracy.org)

Prerequisites: install git, Ruby 3.0.6, CMake, pkg-config, shared-mime-info, Node.js and PostgreSQL (>=9.5).

```bash
git clone https://github.com/consuldemocracy/consuldemocracy.git
cd consuldemocracy
bundle install
cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml
bin/rake db:create
bin/rake db:migrate
bin/rake db:dev_seed
RAILS_ENV=test rake db:setup
```

Run the app locally:

```bash
bin/rails s
```

Run the tests with:

```bash
bin/rspec
```

You can use the default admin user from the seeds file:

 **user:** admin@consul.dev
 **pass:** 12345678

But for some actions like voting, you will need a verified user, the seeds file also includes one:

 **user:** verified@consul.dev
 **pass:** 12345678

## Configuration for production environments

See [installer](https://github.com/consuldemocracy/installer)

## License

Code published under AFFERO GPL v3 (see [LICENSE-AGPLv3.txt](open_source/license.md))

## Contributions

See [CONTRIBUTING.md](https://github.com/consuldemocracy/consuldemocracy/blob/master/CONTRIBUTING.md)
