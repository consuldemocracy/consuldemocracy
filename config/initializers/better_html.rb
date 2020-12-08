if Rails.env.development?
  BetterHtml.configure do |config|
    config.template_exclusion_filter = proc { |filename| true }
  end
end
