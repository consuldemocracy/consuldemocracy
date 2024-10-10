def in_browser(name, &)
  Capybara.using_session(name, &)
end
