if defined? Redis
  redis = Redis.new(url: ENV["REDIS_URL"])
  $redis = Redis::Namespace.new("decidimbcn_#{Rails.env}", redis: redis)
end
