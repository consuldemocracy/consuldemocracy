# Customizing the Gemfile

To add new gems (external tools/libraries written in Ruby) you can edit the `Gemfile_custom` file. For example, to add the [rails-footnotes](https://github.com/josevalim/rails-footnotes) gem you would add:

```ruby
gem "rails-footnotes", "~> 4.0"
```

And then run `bundle install` and follow any gem specific installation steps from its documentation.
