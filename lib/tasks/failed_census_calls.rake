namespace :failed_census_calls do

  desc "Recalculates all the failed census calls counters for users"
  task count: :environment do
    User.all.pluck(:id).each{ |id| User.reset_counters(id, :failed_census_calls) }
  end

end
