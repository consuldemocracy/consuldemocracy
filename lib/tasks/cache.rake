namespace :cache do
  desc "Clears memcached"
  task clear: :environment do
    Rails.cache.clear
  end
end
