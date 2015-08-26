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

Prerequisites: install git, ImageMagick, Ruby 2.2.3, bundler gem, ghostscript and PostgreSQL (>=9.4).

```
cd participacion
bundle install
cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml
bin/rake db:setup
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
