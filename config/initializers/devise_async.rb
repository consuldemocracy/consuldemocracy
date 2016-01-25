Devise::Async.setup do |config|
  if Rails.env.test? || Rails.env.development?
    config.enabled = false
  else
    config.enabled = true
  end
  config.backend = :sidekiq
end
