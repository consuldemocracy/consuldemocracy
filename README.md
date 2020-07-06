# King County Equity Now - Participatory Budgeting Site

This ruby-on-rails site is forked from the [Consul](https://docs.consulproject.org) participatory budgeting open-source project.

## Setup (osx)

Run `script/dev-setup` and follow the instructions until you see:

`>> You're all set up!`

## Running the server

`bin/rails server`

You can use the default admin user from the seeds file:

user: admin@consul.dev pass: 12345678

But for some actions like voting, you will need a verified user, the seeds file also includes one:

user: verified@consul.dev pass: 12345678

## Development

### Running the tests

`bin/rspec`

## License

Like the original project this was forked from, this repository is published under AFFERO GPL v3 (see [LICENSE-AGPLv3.txt](LICENSE-AGPLv3.txt))

