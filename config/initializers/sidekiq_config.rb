if Rails.env.test?
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!
end

redis_config = {
  url: ENV["REDIS_URL"], namespace: "decidimbcn_jobs_#{Rails.env}"
}

Sidekiq.configure_server do |config|
  config.redis = redis_config

  database_url = ENV['DATABASE_URL']
  if database_url
    ENV['DATABASE_URL'] = "#{database_url}?pool=25"
    ActiveRecord::Base.establish_connection
    # Note that as of Rails 4.1 the `establish_connection` method requires
    # the database_url be passed in as an argument. Like this:
    # ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
  end
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
end
