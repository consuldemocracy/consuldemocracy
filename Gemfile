source "https://rubygems.org"

gem "rails", "6.0.6.1"

gem "acts-as-taggable-on", "~> 9.0.1"
gem "acts_as_votable", "~> 0.14.0"
gem "ahoy_matey", "~> 4.2.1"
gem "airbrake", "~> 13.0.2"
gem "ancestry", "~> 4.3.3"
gem "audited", "~> 5.3.3"
gem "autoprefixer-rails", "~> 8.2.0"
gem "bing_translator", "~> 6.2.0"
gem "cancancan", "~> 3.5.0"
gem "caxlsx", "~> 3.4.1"
gem "caxlsx_rails", "~> 0.6.3"
gem "ckeditor", "~> 4.3.0"
gem "cocoon", "~> 1.2.15"
gem "daemons", "~> 1.4.1"
gem "dalli", "~> 3.2.5"
gem "delayed_job_active_record", "~> 4.1.7"
gem "devise", "~> 4.9.2"
gem "devise-security", "~> 0.18.0"
gem "file_validators", "~> 3.0.0"
gem "font-awesome-sass", "~> 5.15.1" # Remember to update vendor/assets/images/fontawesome when updating this gem
gem "foundation-rails", "~> 6.6.2.0"
gem "foundation_rails_helper", "~> 4.0.1"
gem "globalize", "~> 6.2.1"
gem "globalize-accessors", "~> 0.3.0"
gem "graphiql-rails", "~> 1.8.0"
gem "graphql", "~> 1.12.14"
gem "groupdate", "~> 6.2.1"
gem "image_processing", "~> 1.12.2"
gem "initialjs-rails", "~> 0.2.0.9"
gem "invisible_captcha", "~> 2.1.0"
gem "jquery-fileupload-rails"
gem "jquery-rails", "~> 4.6.0"
gem "jquery-ui-rails", "~> 6.0.1"
gem "kaminari", "~> 1.2.2"
gem "leaflet-rails", "~> 1.9.3"
gem "mini_magick", "~> 4.12.0"
gem "omniauth", "~> 2.1.1"
gem "omniauth-facebook", "~> 9.0.0"
gem "omniauth-google-oauth2", "~> 1.1.1"
gem "omniauth-rails_csrf_protection", "~> 1.0.1"
gem "omniauth-twitter", "~> 1.4.0"
gem "paranoia", "~> 2.6.2"
gem "pg", "~> 1.5.4"
gem "pg_search", "~> 2.3.6"
gem "puma", "~> 4.3.12"
gem "recipient_interceptor", "~> 0.3.1"
gem "redcarpet", "~> 3.6.0"
gem "responders", "~> 3.1.0"
gem "rinku", "~> 2.0.6", require: "rails_rinku"
gem "ros-apartment", "~> 2.11.0", require: "apartment"
gem "sassc-rails", "~> 2.1.2"
gem "savon", "~> 2.14.0"
gem "sitemap_generator", "~> 6.3.0"
gem "social-share-button", "~> 1.2.4"
gem "sprockets", "~> 4.2.0"
gem "turbolinks", "~> 5.2.1"
gem "turnout", "~> 2.5.0"
gem "uglifier", "~> 4.2.0"
gem "uuidtools", "~> 2.2.0"
gem "view_component", "~> 3.5.0"
gem "whenever", "~> 1.0.0", require: false
gem "wicked_pdf", "~> 2.7.0"
gem "wkhtmltopdf-binary", "~> 0.12.6"

source "https://rails-assets.org" do
  gem "rails-assets-markdown-it", "~> 9.0.1"
end

group :development, :test do
  gem "bullet", "~> 7.0.7"
  gem "byebug", "~> 11.1.3"
  gem "factory_bot_rails", "~> 6.2.0"
  gem "faker", "~> 3.2.1"
  gem "i18n-tasks", "~> 0.9.37"
  gem "knapsack_pro", "~> 5.6.0"
  gem "launchy", "~> 2.5.2"
  gem "letter_opener_web", "~> 2.0.0"
  gem "spring", "~> 2.1.1"
  gem "spring-commands-rspec", "~> 1.0.4"
end

group :test do
  gem "capybara", "~> 3.39.2"
  gem "capybara-webmock", "~> 0.7.0"
  gem "email_spec", "~> 2.2.2"
  gem "rspec-rails", "~> 5.1.2"
  gem "selenium-webdriver", "~> 4.12.0"
  gem "simplecov", "~> 0.22.0", require: false
  gem "simplecov-lcov", "~> 0.8.0", require: false
end

group :development do
  gem "capistrano", "~> 3.17.3", require: false
  gem "capistrano-bundler", "~> 2.1.0", require: false
  gem "capistrano-rails", "~> 1.6.3", require: false
  gem "capistrano3-delayed-job", "~> 1.7.6"
  gem "capistrano3-puma", "~> 5.2.0"
  gem "erb_lint", "~> 0.5.0", require: false
  gem "mdl", "~> 0.12.0", require: false
  gem "pronto", "~> 0.11.1", require: false
  gem "pronto-erb_lint", "~> 0.1.6", require: false
  gem "pronto-eslint", "~> 0.11.1", require: false
  gem "pronto-rubocop", "~> 0.11.5", require: false
  gem "pronto-scss", "~> 0.11.0", require: false
  gem "rubocop", "~> 1.35.1", require: false
  gem "rubocop-performance", "~> 1.19.0", require: false
  gem "rubocop-rails", "~> 2.15.2", require: false
  gem "rubocop-rspec", "~> 2.4.0", require: false
  gem "rvm1-capistrano3", "~> 1.4.0", require: false
  gem "scss_lint", "~> 0.60.0", require: false
  gem "web-console", "~> 4.2.0"
end

eval_gemfile "./Gemfile_custom"
