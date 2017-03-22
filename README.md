![Logo of Consul](https://raw.githubusercontent.com/consul/consul/master/public/consul_logo.png)

# Consul

Citizen Participation and Open Government Application

[![Build Status](https://travis-ci.org/consul/consul.svg?branch=master)](https://travis-ci.org/consul/consul)
[![Code Climate](https://codeclimate.com/github/consul/consul/badges/gpa.svg)](https://codeclimate.com/github/consul/consul)
[![Dependency Status](https://gemnasium.com/consul/consul.svg)](https://gemnasium.com/consul/consul)
[![Coverage Status](https://coveralls.io/repos/github/consul/consul/badge.svg?branch=master)](https://coveralls.io/github/consul/consul?branch=master)
[![License: AGPL v3](https://img.shields.io/badge/License-AGPL%20v3-blue.svg)](http://www.gnu.org/licenses/agpl-3.0)

[![Accessibility conformance](https://img.shields.io/badge/accessibility-WAI:AA-green.svg)](https://www.w3.org/WAI/eval/Overview)
[![A11y issues checked with Rocket Validator](https://rocketvalidator.com/badges/checked_with_rocket_validator.svg?url=https://rocketvalidator.com)](https://rocketvalidator.com/opensource)

[![Join the chat at https://gitter.im/consul/consul](https://badges.gitter.im/consul/consul.svg)](https://gitter.im/consul/consul?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This is the opensource code repository of the eParticipation website originally developed for the Madrid City government eParticipation website

## Current state

Development started on [2015 July 15th](https://github.com/consul/consul/commit/8db36308379accd44b5de4f680a54c41a0cc6fc6). Code was deployed to production on 2015 september 7th to [decide.madrid.es](https://decide.madrid.es). Since then new features are added often. You can take a look at the current features in the [docs](https://github.com/consul/consul/tree/master/doc) and future features in the [open issues list](https://github.com/consul/consul/issues).

## Tech stack

The application backend is written in the [Ruby language](https://www.ruby-lang.org/) using the [Ruby on Rails](http://rubyonrails.org/) framework.

Frontend tools used include [SCSS](http://sass-lang.com/) over [Foundation](http://foundation.zurb.com/) for the styles.

## Configuration for development and test environments

**NOTE**: For more detailed instructions check the [docs](https://github.com/consul/consul/tree/master/doc/en/dev_test_setup.md)

Prerequisites: install git, Ruby 2.3.2, bundler gem, ghostscript and PostgreSQL (>=9.4).

```
git clone https://github.com/consul/consul.git
cd consul
bundle install
cp config/database.yml.example config/database.yml
cp config/secrets.yml.example config/secrets.yml
bin/rake db:setup
bin/rake db:dev_seed
RAILS_ENV=test rake db:setup
```

Run the app locally:
```
bin/rails s

```

Prerequisites for testing: install PhantomJS >= 1.9.8

Run the tests with:

```
bin/rspec
```

You can use the default admin user from the seeds file:

 **user:** admin@consul.dev
 **pass:** 12345678

But for some actions like voting, you will need a verified user, the seeds file also includes one:

 **user:** verified@consul.dev
 **pass:** 12345678

### Customization

See [CUSTOMIZE_ES.md](CUSTOMIZE_ES.md)

### OAuth

To test authentication services with external OAuth suppliers - right now Twitter, Facebook and Google - you'll need to create an "application" in each of the supported platforms and set the *key* and *secret* provided in your *secrets.yml*

In the case of Google, verify that the APIs *Contacts API* and *Google+ API* are enabled for the application.

## License

Code published under AFFERO GPL v3 (see [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt))

## Contributions

See [CONTRIBUTING_EN.md](CONTRIBUTING_EN.md)
