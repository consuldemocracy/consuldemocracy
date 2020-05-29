namespace :stats do
  desc "Generates stats which are not cached yet"
  task generate: :environment do
    ApplicationLogger.new.info "Updating budget and poll stats"
    admin_ability = Ability.new(Administrator.first.user)

    Budget.accessible_by(admin_ability, :read_stats).find_each do |budget|
      Budget::Stats.new(budget).generate
      print "."
    end

    Poll.accessible_by(admin_ability, :stats).find_each do |poll|
      Poll::Stats.new(poll).generate
      print "."
    end
  end

  desc "Expires stats cache"
  task expire_cache: :environment do
    [Budget, Poll].each do |model_class|
      model_class.find_each { |record| record.find_or_create_stats_version.touch }
    end
  end

  desc "Deletes stats cache and generates it again"
  task regenerate: [:expire_cache, :generate]
end
