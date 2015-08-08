# Ayuntamiento de Madrid (Madrid city's government) eParticipation application

[![Build Status](https://travis-ci.org/AyuntamientoMadrid/participacion.svg?branch=master)](https://travis-ci.org/AyuntamientoMadrid/participacion)
[![Code Climate](https://codeclimate.com/github/AyuntamientoMadrid/participacion/badges/gpa.svg)](https://codeclimate.com/github/AyuntamientoMadrid/participacion)
[![Dependency Status](https://gemnasium.com/AyuntamientoMadrid/participacion.svg)](https://gemnasium.com/AyuntamientoMadrid/participacion)
[![Coverage Status](https://coveralls.io/repos/AyuntamientoMadrid/participacion/badge.svg?branch=master&service=github)](https://coveralls.io/github/AyuntamientoMadrid/participacion?branch=master)

This is the opensource code repository of Madrid City government eParticipation website

## Current state

Development started on [2015 July 15th](https://github.com/AyuntamientoMadrid/participacion/commit/8db36308379accd44b5de4f680a54c41a0cc6fc6)

The project is in its early stages. Features currently present in the code (and their names) are subject to change.

## Tech stack

The application backend is written in the [Ruby language](https://www.ruby-lang.org/) using the [Ruby on Rails](http://rubyonrails.org/) framework.

Frontend tools used include [SCSS](http://sass-lang.com/) over [Foundation](http://foundation.zurb.com/) for the styles.

## Configuration for development and test environments

Prerequisites: install git, Ruby 2.2.2, bundler gem and PostgreSQL.

```
cd participacion
bundle install
cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml
bundle exec bin/rake db:setup
RAILS_ENV=test bundle exec rake db:setup
```

Run the app locally:
```
bundle exec bin/rails s
```

Run the tests with:
```
bundle exec bin/rspec
```

## Configuration for development and test environments with Docker
Install docker from the [docker web](http://docs.docker.com/)
Install docker-compose from the [docker-compose instruction page](http://docs.docker.com/compose/install/)

```
docker-compose build
docker-compose run app bash -c 'bundle install && rake db:setup'

```
Run the app locally:
```
docker-compose up -d
```

Examine logs live:
```
docker-compose logs
```

Run the tests with:
 los tests:
```
docker-compose run app bundle exec rspec
```

You can check transactional mail on http://localhost:1080

## Licence

Code published under MIT license (see [MIT-license.md](MIT-license.md))

## Contributions

See [CONTRIBUTING_EN.md](CONTRIBUTING_EN.md)
