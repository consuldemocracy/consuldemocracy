ENV["RAILS_ENV"] ||= "test"
if ENV["COVERALLS"]
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
require "view_component/test_helpers"

RSpec.configure do |config|
  config.include ViewComponent::TestHelpers, type: :component
end

Rails.application.load_tasks if Rake::Task.tasks.empty?

include Warden::Test::Helpers
Warden.test_mode!

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!
  config.after do
    Warden.test_reset!
  end
end

Capybara.register_driver :headless_chrome do |app|
  capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
    "goog:chromeOptions" => {
      args: %W[headless no-sandbox window-size=1200,600 proxy-server=127.0.0.1:#{Capybara::Webmock.port_number}]
    }
  )

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    desired_capabilities: capabilities
  )
end

Capybara.exact = true
Capybara.enable_aria_label = true

OmniAuth.config.test_mode = true
