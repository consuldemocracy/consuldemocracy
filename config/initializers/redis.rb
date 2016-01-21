if defined? Redis
  $redis = Redis.new(url: ENV["REDIS_URL"])
end
