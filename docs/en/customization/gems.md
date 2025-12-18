# Customizing the Gemfile

To add new gems (external tools/libraries written in Ruby) you can edit the `Gemfile_custom` file. For example, to add the [rails-footnotes](https://github.com/josevalim/rails-footnotes) gem you would add:

```ruby
gem "rails-footnotes", "~> 4.0"
```

And then run `bundle install` and follow any gem specific installation steps from its documentation.

**Note**: it's possible to stumble into conflicts when updating to a new Consul version. In repositories where you haven't added many custom gems, first accept the Gemfile.lock from the new version of Consul and then run `bundle install`. In general, it's recommended to be specific with the versions when defining gems in Gemfile_custom. That way, you won't upgrade these gems when running `bundle install`.
