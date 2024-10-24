# Customizing other Ruby classes

Other than models, controllers and components, there are a few other folders containing Ruby code:

* `app/form_builders/`
* `app/graphql/`
* `app/lib/`
* `app/mailers/`

The files in these folders can be customized like any other Ruby file (see [customizing models](models.md) for more information).

For example, in order to customize the `app/form_builders/consul_form_builder.rb` file, create a file `app/form_builders/custom/consul_form_builder.rb` with the following content:

```ruby
load Rails.root.join("app", "form_builders", "consul_form_builder.rb")

class ConsulFormBuilder
  # Your custom logic here
end
```

Or, in order to customize the `app/lib/remote_translations/caller.rb` file, create a file `app/lib/custom/remote_translations/caller.rb` with the following content:

```ruby
load Rails.root.join("app", "lib", "remote_translations", "caller.rb")

class RemoteTranslations::Caller
  # Your custom logic here
end
```
