# Overwriting application.rb

If you need to extend or modify the `config/application.rb` just do it at the `config/application_custom.rb` file. For example if you want to change de default language to English, just add:

```ruby
module Consul
  class Application < Rails::Application
    config.i18n.default_locale = :en
    config.i18n.available_locales = [:en, :es]
  end
end
```

Remember that in order to see this changes live you'll need to restart the server.
