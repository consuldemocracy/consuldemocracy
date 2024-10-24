require Rails.root.join("config", "environments", "production")

Rails.application.configure do
  config.log_level = :debug
end

require Rails.root.join("config", "environments", "custom", "staging")
