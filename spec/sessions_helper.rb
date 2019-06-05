def in_browser(name, &block)
  Capybara.using_session(name, &block)
end
