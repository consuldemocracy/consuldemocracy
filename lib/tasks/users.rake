namespace :users do

  desc "Recalculates all the failed census calls counters for users"
  task count_failed_census_calls: :environment do
    User.find_each{ |user| User.reset_counters(user.id, :failed_census_calls)}
  end
  
  desc "Assigns official level to users with the officials' email domain"
  task check_email_domains: :environment do
    User.find_each do |user|
      user.check_email_domain
      user.save
    end
  end

end
