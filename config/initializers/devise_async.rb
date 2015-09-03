Devise::Async.setup do |config|
  if Rails.env.test?
    config.enabled = false
  else
    config.enabled = true
  end
  config.backend = :delayed_job
end