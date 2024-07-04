namespace :cache do
  desc "Clears the Rails cache"
  task clear: :environment do
    ApplicationLogger.new.info "Clearing Rails cache"
    Rails.cache.clear
  end
end
