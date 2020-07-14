# Heroku

## Manual deployment

This tutorial assumes that you have already managed to clone CONSUL on your machine and gotten it to work.

1. First, create a [Heroku](https://www.heroku.com) account if it isn't already done.
2. Install the [Heroku CLI](https://devcenter.heroku.com/articles/heroku-cli) and sign in using

   ```text
   heroku login
   ```

3. Go to your CONSUL repository and instantiate the process

   ```text
   cd consul
   heroku create your-app-name
   ```

   You can add the flag `--region eu` if you want to use their European servers instead of the US ones.

   If _your-app-name_ is not already taken, Heroku should now create your app.

4. Create a database using

   ```text
   heroku addons:create heroku-postgresql
   ```

   You should now have access to an empty Postgres database whose address was automatically saved as an environment variable named _DATABASE\_URL_. CONSUL will automatically connect to it when deployed.

5. Add a file name _heroku.yml_ at the root of your project and paste the following in it

   ```text
    build:
      languages:
        - ruby
      packages:
        - imagemagick
    run:
      web: bundle exec rails server -e ${RAILS_ENV:-production}
   ```

6. Now, generate a secret key and save it to an ENV variable named SECRET\_KEY\_BASE using

   ```text
    heroku config:set SECRET_KEY_BASE=`ruby -rsecurerandom -e "puts SecureRandom.hex(64)"
   ```

   You need to let the app know where the secret key is stored by adding a link to the ENV variable in _config/secrets.yml_

   ```text
    production:
      secret_key_base: <%= ENV["SECRET_KEY_BASE"] %>
   ```

   and commit this file in the repo by commenting out the corresponding line in the _.gitignore_.

   ```text
    #/config/secrets.yml
   ```

   **Remember not to commit the file if you have any sensitive information in it!**

7. You can now push your app using

   ```text
    git push heroku your-branch:master
   ```

8. It won't work straight away because the database doesn't contain the tables needed. To create them, run

   ```text
    heroku run rake db:migrate
    heroku run rake db:seed
   ```

   If you want to add the test data in the database, move `gem 'faker', '~> 1.8.7'` outside of `group :development` and run

   ```text
    heroku config:set DATABASE_CLEANER_ALLOW_REMOTE_DATABASE_URL=true
    heroku config:set DATABASE_CLEANER_ALLOW_PRODUCTION=true
    heroku run rake db:dev_seed
   ```

9. Your app should now be ready to use. You can open it with

   ```text
    heroku open
   ```

   You also can run the console on heroku using

   ```text
    heroku console --app your-app-name
   ```

10. Heroku doesn't allow to save images or documents in its servers, so it's necessary make this changes

    On `app/models/image.rb:47` and `app/models/document.rb:39`

    Change `URI.parse(cached_attachment)` to `URI.parse("http:" + cached_attachment)`

    Create a new file on `config/initializers/paperclip.rb` with the following content

    ```text
    Paperclip::UriAdapter.register
    ```

    See [our S3 guide](https://github.com/consul/docs/tree/93ee83681d6a2c8f49d0c38559083bddf6855ef2/es/getting_started/using-aws-s3-as-storage.md) for more details about configuring Paperclip with S3.

### Optional but recommended:

**Install rails\_12factor and specify the Ruby version**

As recommended by Heroku, you can add the gem rails\_12factor and specify the version of Ruby you want to use. You can do so by adding

```text
gem 'rails_12factor'

ruby 'x.y.z'
```

in the file _Gemfile\_custom_, where `x.y.z` is the version defined in the `.ruby-version` file in the CONSUL repository. Don't forget to run

```text
bundle install
```

to generate _Gemfile.lock_ before commiting and pushing to the server.

### Optional but recommended:

**Use Puma as a web server**

Heroku recommends to use Puma instead of the default web server to improve the responsiveness of your app on [a number of levels](http://blog.scoutapp.com/articles/2017/02/10/which-ruby-app-server-is-right-for-you). First, add the gem in your _Gemfile\_custom_ file:

```text
  gem 'puma'
```

Then you need to create a new file named _puma.rb_ \(your _config_ folder is a good place to store it\). Here is a standard content for this file:

```text
  workers Integer(ENV['WEB_CONCURRENCY'] || 1)
  threads_count = Integer(ENV['RAILS_MAX_THREADS'] || 5)
  threads threads_count, threads_count

  preload_app!

  rackup      DefaultRackup
  port        ENV['PORT']     || 3000
  environment ENV['RACK_ENV'] || 'production'

  on_worker_boot do
    # Worker specific setup for Rails 4.1+
    # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
    ActiveRecord::Base.establish_connection
  end
```

You can find an explanation for each of these settings in the [Heroku tutorial](https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server).

The last part is to change the _web_ task to use Puma by changing it to this in your _heroku.yml_ file:

```text
  web: bundle exec puma -C config/puma.rb
```

