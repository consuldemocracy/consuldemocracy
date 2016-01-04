![Logo of Consul]
(https://raw.githubusercontent.com/consul/consul/master/public/consul_logo.png)

# Consul

Citizen Participation and Open Government Application

[![Build Status](https://travis-ci.org/AjuntamentdeBarcelona/barcelona-participa.svg?branch=master)](https://travis-ci.org/AjuntamentdeBarcelona/barcelona-participa)
[![Code Climate](https://codeclimate.com/github/AjuntamentdeBarcelona/barcelona-participa/badges/gpa.svg)](https://codeclimate.com/github/AjuntamentdeBarcelona/barcelona-participa)
[![Dependency Status](https://gemnasium.com/AjuntamentdeBarcelona/barcelona-participa.svg)](https://gemnasium.com/AjuntamentdeBarcelona/barcelona-participa)
[![Coverage Status](https://coveralls.io/repos/AjuntamentdeBarcelona/barcelona-participa/badge.svg?branch=master&service=github)](https://coveralls.io/github/AjuntamentdeBarcelona/barcelona-participa?branch=master)
[![Deploy](https://www.herokucdn.com/deploy/button.svg)](https://heroku.com/deploy)

This is the opensource code repository of the eParticipation website originally developed for the Madrid City government eParticipation website

## Current state

Development started on [2015 July 15th](https://github.com/consul/consul/commit/8db36308379accd44b5de4f680a54c41a0cc6fc6). Code was deployed to production on 2015 september 7th to [decide.madrid.es](https://decide.madrid.es). Since then new features are added often. You can take a look at a roadmap and future features in the [open issues list](https://github.com/consul/consul/issues).

## Roadmap

See [ROADMAP_ES.md](ROADMAP_ES.md)

## Tech stack

The application backend is written in the [Ruby language](https://www.ruby-lang.org/) using the [Ruby on Rails](http://rubyonrails.org/) framework.

Frontend tools used include [SCSS](http://sass-lang.com/) over [Foundation](http://foundation.zurb.com/) for the styles.

## Configuration for development environment using docker

```
docker-compose build
docker-compose run --rm app db:create           
docker-compose run --rm app db:setup SEED=true
docker-compose up
```

## Configuration for development and test environments

Prerequisites: install git, ImageMagick, Ruby 2.2.3, bundler gem, ghostscript and PostgreSQL (>=9.4).

```
git clone https://github.com/consul/consul.git
cd consul
bundle install
cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml
rake db:create
bin/rake db:setup
bin/rake db:dev_seed
RAILS_ENV=test bin/rake db:setup
```

Run the app locally:
```
bin/rails s
```

Prerequisites for testing: install PhantomJS >= 2.0

Run the tests with:

```
bin/rspec
```

## Licence

Code published under AFFERO GPL v3 (see [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt))

## Contributions

See [CONTRIBUTING_EN.md](CONTRIBUTING_EN.md)
