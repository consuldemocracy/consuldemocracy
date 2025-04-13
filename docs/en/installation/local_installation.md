# Local installation

Before installing Consul Democracy and having it up and running make sure you have all [prerequisites](prerequisites.md) installed.

The installation process will vary depending on your operating system:

- [Ubuntu Linux](ubuntu.md)
- [Debian Linux](debian.md)
- [macOS](macos.md)
- [Windows](windows.md)

1. First, clone the [Consul Democracy Github repository](https://github.com/consuldemocracy/consuldemocracy/) and enter the project folder:

```bash
git clone https://github.com/consuldemocracy/consuldemocracy.git
cd consuldemocracy
```

2. Install the Ruby version we need with your Ruby version manager. Here are some examples:

```bash
rbenv install `cat .ruby-version` # If you're using rbenv
rvm install `cat .ruby-version` # If you're using RVM
asdf install ruby `cat .ruby-version` # If you're using asdf
```

3. Check we're using the Ruby version we've just installed:

```bash
ruby -v
=> # (it should be the same as the version in the .ruby-version file)
```

4. Install the Node.js version we need with your Node.js version manager. If you're using NVM:

```bash
nvm install `cat .node-version`
nvm use `cat .node-version`
```

5. Copy the example database configuration file:

```bash
cp config/database.yml.example config/database.yml
```

6. Setup database credentials with your `consul` user in your new `database.yml` file

Note: this step is not necessary if you're using a database user without a password and the same username as your system username, which is the default in macOS.

```bash
nano config/database.yml
```

And edit the lines containing `username:` and `password:`, adding your credentials.

7. Install the project dependencies and create the database:

```bash
bin/setup
```

8. Run the following [Rake task](https://github.com/ruby/rake) to fill your local database with development data:

```bash
bin/rake db:dev_seed
```

9. Check everything is fine by running the test suite

Note: running the whole test suite on your machine might take more than an hour, so it's strongly recommended that you setup a Continuous Integration system in order to run them using parallel jobs every time you open or modify a pull request (if you use GitHub Actions or GitLab CI, this is already configured in `.github/workflows/tests.yml` and `.gitlab-ci.yml`) and only run tests related to your current task while developing on your machine. When you configure the application for the first time, it's recommended that you run at least one test in `spec/models/` and one test in `spec/system/` to check your machine is properly configured to run the tests.

```bash
bin/rspec
```

10. Now you have all set, run the application:

```bash
bin/rails s
```

Congratulations! Your local Consul Democracy application will be running now at `http://localhost:3000`.

In case you want to access the local application as admin, a default user verified and with admin permissions was created by the seed files with **username** `admin@consul.dev` and **password** `12345678`.

If you need an specific user to perform actions such as voting without admin permissions, a default verified user is also available with **username** `verified@consul.dev` and **password** `12345678`.
