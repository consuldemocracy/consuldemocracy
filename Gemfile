source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.7.1'
# Use PostgreSQL
gem 'pg', '~> 0.19.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0', '>= 5.0.4'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 3.0.4'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2.1'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.2.1'
gem 'jquery-ui-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Fix sprockets on the
gem 'sprockets', '~> 3.7.0'

gem 'devise', '~> 3.5.7'
gem 'devise_security_extension'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook', '~> 3.0.0'
gem 'omniauth-google-oauth2', '~> 0.4.0'

gem 'kaminari'
gem 'ancestry', '~> 2.2.2'
gem 'acts-as-taggable-on'
gem 'responders', '~> 2.3.0'
gem 'foundation-rails', '~> 6.2.4.0'
gem 'foundation_rails_helper', '~> 2.0.0'
gem 'acts_as_votable'
gem 'ckeditor', '~> 4.2.0'
gem 'invisible_captcha', '~> 0.9.1'
gem 'cancancan'
gem 'social-share-button'
gem 'initialjs-rails', '0.2.0.4'
gem 'unicorn', '~> 5.1.0'
gem 'paranoia', '~> 2.2.0'
gem 'rinku', '~> 2.0.2', require: 'rails_rinku'
gem 'savon'
gem 'dalli'
gem 'rollbar', '~> 2.13.3'
gem 'delayed_job_active_record', '~> 4.1.0'
gem 'daemons'
gem 'devise-async'
gem 'newrelic_rpm', '~> 3.17.1.326'
gem 'whenever', require: false
gem 'pg_search'
gem 'sitemap_generator'

gem 'ahoy_matey', '~> 1.4.2'
gem 'groupdate', '~> 3.1.0' # group temporary data
gem 'tolk', '~> 2.0.0' # Web interface for translations

gem 'browser'
gem 'turnout', '~> 2.4.0'
gem 'redcarpet'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'rspec-rails', '~> 3.5'
  gem 'capybara'
  gem 'factory_girl_rails'
  gem 'fuubar'
  gem 'launchy'
  gem 'quiet_assets'
  gem 'letter_opener_web', '~> 1.3.0'
  gem 'i18n-tasks'
  gem 'capistrano', '3.5.0',           require: false
  gem 'capistrano-bundler', '~> 1.2',  require: false
  gem "capistrano-rails", '1.1.8',     require: false
  gem 'rvm1-capistrano3',              require: false
  gem 'capistrano3-delayed-job', '~> 1.0'
  gem "bullet"
  gem "faker"
  gem 'rubocop', '~> 0.45.0', require: false
  gem 'knapsack'
end

group :test do
  gem 'database_cleaner'
  gem 'poltergeist'
  gem 'coveralls', require: false
  gem 'email_spec'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '3.3.0'
end

eval_gemfile './Gemfile_custom'
