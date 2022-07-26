source "https://rubygems.org"

gem "rails", "5.2.8.1"

gem "acts-as-taggable-on", "~> 8.1.0"
gem "acts_as_votable", "~> 0.13.1"
gem "ahoy_matey", "~> 3.2.0"
gem "airbrake", "~> 11.0.3"
gem "ancestry", "~> 4.1.0"
gem "audited", "~> 5.0.1"
gem "autoprefixer-rails", "~> 8.2.0"
gem "cancancan", "~> 3.3.0"
gem "caxlsx", "~> 3.1.0"
gem "caxlsx_rails", "~> 0.6.2"
gem "ckeditor", "~> 4.3.0"
gem "cocoon", "~> 1.2.15"
gem "daemons", "~> 1.4.0"
gem "dalli", "~> 2.7.11"
gem "delayed_job_active_record", "~> 4.1.6"
gem "devise", "~> 4.8.0"
gem "devise-security", "~> 0.16.0"
gem "file_validators", "~> 3.0.0"
gem "font-awesome-sass", "~> 5.15.1" # Remember to update vendor/assets/images/fontawesome when updating this gem
gem "foundation-rails", "~> 6.6.2.0"
gem "foundation_rails_helper", "~> 4.0.0"
gem "globalize", "~> 6.0.1"
gem "globalize-accessors", "~> 0.3.0"
gem "graphiql-rails", "~> 1.7.0"
gem "graphql", "~> 1.12.14"
gem "groupdate", "~> 5.2.2"
gem "initialjs-rails", "~> 0.2.0.9"
gem "invisible_captcha", "~> 2.0.0"
gem "jquery-fileupload-rails"
gem "jquery-rails", "~> 4.4.0"
gem "jquery-ui-rails", "~> 6.0.1"
gem "kaminari", "~> 1.2.1"
gem "mini_magick", "~> 4.11.0"
gem "omniauth", "~> 2.0.4"
gem "omniauth-facebook", "~> 8.0.0"
gem "omniauth-google-oauth2", "~> 1.0.0"
gem "omniauth-rails_csrf_protection", "~> 1.0.0"
gem "omniauth-twitter", "~> 1.4.0"
gem "paranoia", "~> 2.4.3"
gem "pg", "~> 1.2.3"
gem "pg_search", "~> 2.3.5"
gem "puma", "~> 4.3.12"
gem "recipient_interceptor", "~> 0.3.0"
gem "redcarpet", "~> 3.5.1"
gem "responders", "~> 3.0.1"
gem "rinku", "~> 2.0.6", require: "rails_rinku"
gem "sassc-rails", "~> 2.1.2"
gem "savon", "~> 2.12.1"
gem "sitemap_generator", "~> 6.1.2"
gem "social-share-button", "~> 1.2.4"
gem "sprockets", "~> 4.0.2"
gem "translator-text", "~> 0.1.0"
gem "turbolinks", "~> 5.2.1"
gem "turnout", "~> 2.5.0"
gem "uglifier", "~> 4.2.0"
gem "uuidtools", "~> 2.1.5"
gem "view_component", "~> 2.49.1"
gem "whenever", "~> 1.0.0", require: false
gem "wicked_pdf", "~> 2.1.0"
gem "wkhtmltopdf-binary", "~> 0.12.6"

source "https://rails-assets.org" do
  gem "rails-assets-leaflet"
  gem "rails-assets-markdown-it", "~> 9.0.1"
end

group :development, :test do
  gem "bullet", "~> 6.1.4"
  gem "byebug", "~> 11.1.3"
  gem "database_cleaner", "~> 2.0.1"
  gem "factory_bot_rails", "~> 6.2.0"
  gem "faker", "~> 2.18.0"
  gem "i18n-tasks", "~> 0.9.34"
  gem "knapsack_pro", "~> 3.0.0"
  gem "launchy", "~> 2.5.0"
  gem "letter_opener_web", "~> 1.4.0"
  gem "spring", "~> 2.1.1"
  gem "spring-commands-rspec", "~> 1.0.4"
end

group :test do
  gem "capybara", "~> 3.35.3"
  gem "capybara-webmock", "~> 0.6.0"
  gem "coveralls", "~> 0.8.23", require: false
  gem "email_spec", "~> 2.2.0"
  gem "rspec-rails", "~> 5.0"
  gem "selenium-webdriver", "~> 3.142"
  gem "webdrivers", "~> 4.6.0"
end

group :development do
  gem "capistrano", "~> 3.16.0", require: false
  gem "capistrano-bundler", "~> 2.0", require: false
  gem "capistrano-rails", "~> 1.6.1", require: false
  gem "capistrano3-delayed-job", "~> 1.7.6"
  gem "capistrano3-puma", "~> 5.0.4"
  gem "erb_lint", "~> 0.0.37", require: false
  gem "github_changelog_generator", "~> 1.15.2"
  gem "mdl", "~> 0.11.0", require: false
  gem "pronto", "~> 0.11.0", require: false
  gem "pronto-erb_lint", "~> 0.1.5", require: false
  gem "pronto-eslint", "~> 0.11.0", require: false
  gem "pronto-rubocop", "~> 0.11.1", require: false
  gem "pronto-scss", "~> 0.11.0", require: false
  gem "rubocop", "~> 1.18.4", require: false
  gem "rubocop-performance", "~> 1.11.4", require: false
  gem "rubocop-rails", "~> 2.11.3", require: false
  gem "rubocop-rspec", "~> 2.4.0", require: false
  gem "rvm1-capistrano3", "~> 1.4.0", require: false
  gem "scss_lint", "~> 0.59.0", require: false
  gem "web-console", "~> 3.7.0"
end

eval_gemfile "./Gemfile_custom"
