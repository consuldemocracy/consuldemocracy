namespace :stats do
  desc "Expires stats cache"
  task expire_cache: :environment do
    Tenant.run_on_each do
      [Budget, Poll].each do |model_class|
        model_class.find_each { |record| record.find_or_create_stats_version.touch }
      end
    end
  end
end
