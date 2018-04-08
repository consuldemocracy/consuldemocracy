source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.0.4'

# Use PostgreSQL
gem 'pg', '~> 0.20.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0', '>= 5.0.6'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2.1'
# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby


# Use jquery as the JavaScript library
gem 'jquery-rails', '~> 4.3.1'
gem 'jquery-ui-rails'
gem 'jquery-fileupload-rails'
gem 'cocoon', '~> 1.2.9'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks', '~> 5.0.1'

gem 'graphiql-rails', '~> 1.4.1'
gem 'graphql', '~> 1.7.8'

# Fix sprockets on the
gem 'sprockets', '~> 3.7.1'
gem 'devise', '~> 4.3.0'
gem 'devise_security_extension', git: 'https://github.com/phatworx/devise_security_extension.git' #, '~> 0.10'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-facebook', '~> 4.0.0'
gem 'omniauth-google-oauth2', '~> 0.4.1'

gem 'kaminari', '~> 1.0.1'
gem 'ancestry', '~> 2.2.2'
gem 'acts-as-taggable-on'
gem 'responders', '~> 2.4.0'
gem 'foundation-rails', '~> 6.2.4.0'
gem 'foundation_rails_helper', '~> 2.0.0'
gem 'acts_as_votable'
gem 'delayed_job_active_record', '~> 4.1.1'
gem 'ckeditor', '~> 4.2.3'
gem 'invisible_captcha', git: 'https://github.com/xuanxu/invisible_captcha.git', branch: 'rails5'
gem 'cancancan', '~> 2.0.0'
gem 'social-share-button', '~> 0.10'
gem 'initialjs-rails', '0.2.0.4'
gem 'paranoia', '~> 2.3.1'
gem 'rinku', '~> 2.0.2', require: 'rails_rinku'
gem 'savon'
gem 'dalli'
gem 'rollbar', '~> 2.14.1'
gem 'daemons'
gem 'devise-async'
gem 'newrelic_rpm', '~> 4.1.0.333'
gem 'whenever', require: false
gem 'pg_search'
gem 'paperclip', '~> 5.2.1'
gem 'redcarpet', '~> 3.4.0'
gem 'sitemap_generator', '~> 5.3.1'
gem 'ahoy_matey', '~> 1.6.0'
gem 'groupdate', '~> 3.2.0' # group temporary data
gem 'tolk', '~> 2.0.0' # Web interface for translations
gem 'browser'
gem 'turnout', '~> 2.4.0'
gem 'uglifier', '~> 4.1.2'
gem 'unicorn', '~> 5.4.0'
gem 'record_tag_helper', '~> 1.0'
gem 'rb-readline'

source 'https://rails-assets.org' do
  gem 'rails-assets-leaflet'
  gem 'rails-assets-markdown-it', '~> 8.2.1'
end

group :development, :test do
  gem 'byebug'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'rspec-rails', '~> 3.6'
  gem 'factory_bot_rails', '~> 4.8.2'
  gem 'fuubar'
  gem 'launchy'
  gem 'selenium-webdriver', require: false
  gem 'bullet', '~> 5.7.0'
  gem 'faker', '~> 1.8.7'
  gem 'i18n-tasks', '~> 0.9.20'
  gem 'knapsack_pro', '~> 0.53.0'
  gem 'letter_opener_web', '~> 1.3.2'
end

group :test do
  gem 'capybara', '~> 2.17.0'
  gem 'coveralls', '~> 0.8.21', require: false
  gem 'database_cleaner', '~> 1.6.1'
  gem 'email_spec', '~> 2.1.0'
end

group :development do
  gem 'capistrano', '~> 3.10.1', require: false
  gem 'capistrano-bundler', '~> 1.2', require: false
  gem 'capistrano-rails', '~> 1.3.1', require: false
  gem 'capistrano3-delayed-job', '~> 1.7.3'
  gem 'rvm1-capistrano3', '~> 1.4.0', require: false
  gem 'rubocop', '~> 0.54.0', require: false
  gem 'rubocop-rspec', '~> 1.24.0', require: false
  gem 'mdl', require: false
  gem 'web-console', '3.5.1'
  gem 'scss_lint', require: false
end

eval_gemfile './Gemfile_custom'