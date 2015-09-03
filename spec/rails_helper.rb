require 'coveralls'
Coveralls.wear!('rails')
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'spec_helper'
require 'capybara/rails'
require 'capybara/rspec'
require 'capybara/poltergeist'

I18n.default_locale = :en

include Warden::Test::Helpers
Warden.test_mode!

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
end

Capybara.javascript_driver = :poltergeist
Capybara.exact = true

OmniAuth.config.test_mode = true
