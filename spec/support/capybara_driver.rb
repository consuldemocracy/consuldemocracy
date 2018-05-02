# in case you wanna run it with selenium
# FIREFOX=true rspec
if ENV['FIREFOX'] == 'true'
  require 'selenium-webdriver'
  Capybara.javascript_driver = :selenium
  Capybara.register_driver :selenium do |app|
    profile = Selenium::WebDriver::Firefox::Profile.new
    Capybara::Selenium::Driver.new(app, :browser => :firefox, profile: profile)
  end
end
