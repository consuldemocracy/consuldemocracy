# Local installation

Before installing Consul and having it up and running make sure you all [prerequisites](prerequisites) installed.

1. First, clone the [Consul Github repository](https://github.com/consul/consul/):

  ```bash
  git clone https://github.com/consul/consul.git
  ```

2. Go to the project folder and install the gems stack using [Bundler](http://bundler.io/):

  ```bash
  cd consul
  bundle install
  ```

3. Copy the environment example configuration files inside new readable ones:

  ```bash
  cp config/database.yml.example config/database.yml
  cp config/secrets.yml.example config/secrets.yml
  ```

  And setup database credentials with your `consul` user in your new `database.yml` file.

4. Run the following [Rake tasks](https://github.com/ruby/rake) to create and fill your local database with the minimum data to run the application:

  ```bash
  bin/rake db:create
  bin/rake db:setup
  bin/rake db:dev_seed
  RAILS_ENV=test bin/rake db:setup
  ```

5. Check everything is fine by running the test suite (beware it takes some long minutes):

  ```bash
  bundle exec rspec
  ```

6. Now you have all set, run the application:

  ```bash
  rails s
  ```

  Congratulations! Your local Consul application will be running now at `http://localhost:3000`.

In case you want to access the local application as admin, a default user verified and with admin permissions was created by the seed files with **username** `admin@consul.dev` and **password** `12345678`.

If you need an specific user to perform actions such as voting without admin permissions, a default verified user is also available with **username** `verified@consul.dev` and **password** `12345678`.
