# in case you wanna run it with selenium
# FIREFOX=true rspec
if ENV['FIREFOX'] == 'true'
  require 'selenium-webdriver'
  Capybara.javascript_driver = :selenium
  Capybara.register_driver :selenium do |app|
    profile = Selenium::WebDriver::Firefox::Profile.new
    Capybara::Selenium::Driver.new(app, :browser => :firefox, profile: profile)
  end
else
  require 'capybara/poltergeist'
  Capybara.javascript_driver = :poltergeist
  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app,
        js_errors:         true,
        timeout:           1.minute,
        inspector:         true, # allows remote debugging by executing page.driver.debug
        phantomjs_logger:  File.open(File::NULL, "w"), # don't print console.log calls in console
        phantomjs_options: ['--load-images=no', '--disk-cache=false'],
        extensions:        [File.expand_path("../phantomjs_ext/disable_js_fx.js", __FILE__)] # disable js effects
      )
  end
end
