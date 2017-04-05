# in case you wanna run it with selenium
# FIREFOX=true rspec
if ENV['FIREFOX'] == 'true'
  require 'selenium-webdriver'
  Capybara.javascript_driver = :selenium

  # Default download directory for firefox
  Capybara.register_driver :selenium do |app|
    profile = Selenium::WebDriver::Firefox::Profile.new
    Capybara::Selenium::Driver.new(app, :browser => :firefox, profile: profile)
  end

else
  require 'capybara/poltergeist'
  Capybara.javascript_driver = :poltergeist

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app, {
      js_errors: true,
      inspector: true,
      phantomjs_options: ['--load-images=no', '--ignore-ssl-errors=yes'],
      debug: false,
      timeout: 120
    })
  end
end
