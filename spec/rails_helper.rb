ENV["RAILS_ENV"] ||= "test"
if ENV["TRAVIS"]
  require "coveralls"
  Coveralls.wear!("rails")
end
require File.expand_path("../../config/environment", __FILE__)
abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
require "spec_helper"
require "capybara/rails"
require "capybara/rspec"
require "selenium/webdriver"

Rails.application.load_tasks if Rake::Task.tasks.empty?
I18n.default_locale = :en

include Warden::Test::Helpers
Warden.test_mode!

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.after do
    Warden.test_reset!
  end
end

Capybara.register_driver :chrome do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    chromeOptions: { args: %w(headless no-sandbox window-size=1200,600) }
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end

Capybara.javascript_driver = :headless_chrome

Capybara.exact = true

OmniAuth.config.test_mode = true

# Perform a Capybara.visit to the given subdomain.
def visit_path(path, subdomain:)
  MultitenantHelper.set_capybara_subdomain(to_subdomain: subdomain)
  Capybara.visit path
end

def reset_capybara_host()
  MultitenantHelper.reset
end

module MultitenantHelper
  def self.set_capybara_subdomain(to_subdomain:)
    Capybara.current_session.driver.reset!
    Capybara.app_host = "http://#{to_subdomain}.lvh.me"
    Capybara.always_include_port = true
  end

  def self.set_capybara_host(to_host:)
    Capybara.current_session.driver.reset!
    Capybara.app_host = "http://#{to_host}"
    Capybara.always_include_port = true
  end

  def self.reset()
    Capybara.current_session.driver.reset!
    Capybara.app_host = nil
    Capybara.always_include_port = true
  end
end
