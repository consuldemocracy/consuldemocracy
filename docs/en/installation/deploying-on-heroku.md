# Deploying on Heroku

## Manual deployment

This tutorial assumes that you have already managed to clone CONSUL on your machine and gotten it to work.

1. First, create a [Heroku](https://www.heroku.com) account if it isn't already done.
2. Install the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) and sign in using

  ```bash
  heroku login
  ```

3. Go to your CONSUL repository and instantiate the process

  ```bash
  cd consul
  heroku create your-app-name
  ```

  You can add the flag `--region eu` if you want to use their European servers instead of the US ones.

  If _your-app-name_ is not already taken, Heroku should now create your app.

4. Create a database using

  ```bash
  heroku addons:create heroku-postgresql
  ```

  You should now have access to an empty Postgres database whose address was automatically saved as an environment variable named _DATABASE\_URL_. CONSUL will automatically connect to it when deployed.

5. **(Not needed)** Add a file name _heroku.yml_ at the root of your project and paste the following in it

  ```yml
  build:
    languages:
      - ruby
    packages:
      - imagemagick
  run:
    web: bundle exec rails server -e ${RAILS_ENV:-production}
  ```

6. Now, generate a secret key and save it to an ENV variable named SECRET\_KEY\_BASE using

  ```bash
  heroku config:set SECRET_KEY_BASE=$(rails secret)
  ```

  Also add your server address:

  ```bash
  heroku config:set SERVER_NAME=myserver.address.com
  ```

  You need to let the app know where the configuration variables are stored by adding a link to the ENV variables in _config/secrets.yml_

  ```yml
  production:
    secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
    server_name: <%= ENV["SERVER_NAME"] %>
  ```

  and commit this file in the repo by commenting out the corresponding line in the _.gitignore_.

  ```gitignore
  #/config/secrets.yml
  ```

  **Remember not to commit the file if you have any sensitive information in it!**

7. You can now push your app using

  ```bash
  git push heroku your-branch:master
  ```

8. It won't work straight away because the database doesn't contain the tables needed. To create them, run

  ```bash
  heroku run rake db:migrate
  heroku run rake db:seed
  ```

  If you want to add the test data in the database, move `gem 'faker', '~> 1.8.7'` outside of `group :development` and run

  ```bash
  heroku config:set DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL=true
  heroku config:set DATABASE_CLEANER_ALLOW_PRODUCTION=true
  heroku run rake db:dev_seed
  ```

9. Your app should now be ready to use. You can open it with

  ```bash
  heroku open
  ```

  You also can run the console on heroku using

  ```bash
  heroku console --app your-app-name
  ```

10. Heroku doesn't allow to save images or documents in its servers, so it's necessary to setup a permanent storage space.

  See [our S3 guide](./using-aws-s3-as-storage.md) for more details about configuring Paperclip with S3.

### Configure Sendgrid

Add the SendGrid add-on in Heroku. It will create a SendGrid account for you with `ENV["SENDGRID_USERNAME"]` and `ENV["SENDGRID_PASSWORD"]`.

Add this to `config/secrets.yml`, under the `production:` section:

```
  mailer_delivery_method: :smtp
  smtp_settings:
    :address: "smtp.sendgrid.net"
    :port: 587
    :domain: "heroku.com"
    :user_name: ENV["SENDGRID_USERNAME"]
    :password: ENV["SENDGRID_PASSWORD"]
    :authentication: "plain"
    :enable_starttls_auto: true
```

Important: Turn on one worker dyno so that emails get sent.

## Optional but recommended:

### Install rails\_12factor and specify the Ruby version

**The rails\_12factor is only useful if you use a version of CONSUL older than 1.0.0. The latter uses Rails 5 which includes the changes.**

As recommended by Heroku, you can add the gem rails\_12factor and specify the version of Ruby you want to use. You can do so by adding

```ruby
gem 'rails_12factor'

ruby 'x.y.z'
```

in the file _Gemfile\_custom_, where `x.y.z` is the version defined in the `.ruby-version` file in the CONSUL repository. Don't forget to run

```bash
bundle install
```

to generate _Gemfile.lock_ before committing and pushing to the server.

### Use Puma as a web server

Heroku recommends to use Puma to improve the responsiveness of your app on [a number of levels](http://blog.scoutapp.com/articles/2017/02/10/which-ruby-app-server-is-right-for-you).

If you want to allow more concurrency, uncomment the line:

```ruby
workers ENV.fetch("WEB_CONCURRENCY") { 2 }
```

You can find an explanation for each of these settings in the [Heroku tutorial](https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server).

The last part is to change the _web_ task to use Puma by changing it to this in your _heroku.yml_ file:

```yml
web: bundle exec puma -C config/puma.rb
```

### Add configuration variables to tune your app from the dashboard

The free and hobby versions of Heroku are barely enough to run an app like CONSUL. To optimise the response time and make sure the app doesn't run out of memory, you can [change the number of workers and threads](https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#workers) that Puma uses.

My recommended settings are one worker and three threads. You can set it by running these two commands:

```bash
heroku config:set WEB_CONCURRENCY=1
heroku config:set RAILS_MAX_THREADS=3
```

I also recommend to set the following:
```bash
heroku config:set RAILS_SERVE_STATIC_FILES=enabled
heroku config:set RAILS_ENV=production
```
