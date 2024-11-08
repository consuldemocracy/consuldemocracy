# Customizing application configuration

## Overwriting application.rb

If you need to extend or modify the `config/application.rb` file, you can do so using the `config/application_custom.rb` file. For example, if you'd like to change the application timezone to the Canary Islands, just add:

```ruby
module Consul
  class Application < Rails::Application
    config.time_zone = "Atlantic/Canary"
  end
end
```

In this particular case, note that the application time zone can alternatively be modified by editing the `config/secrets.yml` file.

Remember that in order to apply these changes you'll need to restart the application.

## Overwriting environment configuration

If you'd like to customize the development, test, staging, preproduction or production environments, you can do so by editing the files under `config/environments/custom/`.

Note that changes in `config/environments/custom/production.rb` are also applied to the staging and preproduction environments, and changes in `config/environments/custom/staging.rb` are also applied to the preproduction environment.

And remember that in order to apply these changes you'll need to restart the application.
