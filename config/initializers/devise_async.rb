Devise::Async.setup do |config|
  config.enabled = true
  config.backend = :delayed_job
end