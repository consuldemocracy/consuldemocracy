![CONSUL DEMOCRACY logo](../img/consul_logo.png)

# CONSUL DEMOCRACY

Citizen Participation and Open Government Application

## CONSUL DEMOCRACY Foundation and project website

You can access the main website of the project at [http://consuldemocracy.org](http://consuldemocracy.org) where you can find information about the use of the platform, the CONSUL DEMOCRACY Foundation, the global community of users and local partners, news, and ways to get more support or get in touch.

## Configuration for development and test environments

**NOTE**:
The installation process will vary depending on your operating system. Please make sure to follow the [local installation docs](installation/local_installation.md) appropriate for your OS.

Prerequisites: install git, Ruby 3.3.11, CMake, pkg-config, Node.js 20.20.2, ImageMagick and PostgreSQL (>=13).

**Note**: The `bin/setup` command below might fail if you've configured a username and password for PostgreSQL. If that's the case, edit the lines containing `username:` and `password:` (adding your credentials) in the `config/database.yml` file and run `bin/setup` again.

```bash
git clone https://github.com/consuldemocracy/consuldemocracy.git
cd consuldemocracy
bin/setup
bin/rake db:dev_seed
```

Run the app locally:

```bash
bin/rails s
```

You can run the tests with:

```bash
bin/rspec
```

Note: running the whole test suite on your machine might take more than an hour, so it's strongly recommended that you setup a Continuous Integration system in order to run them using parallel jobs every time you open or modify a pull request (if you use GitHub Actions or GitLab CI, this is already configured in `.github/workflows/tests.yml` and `.gitlab-ci.yml`) and only run tests related to your current task while developing on your machine. When you configure the application for the first time, it's recommended that you run at least one test in `spec/models/` and one test in `spec/system/` to check your machine is properly configured to run the tests.

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
