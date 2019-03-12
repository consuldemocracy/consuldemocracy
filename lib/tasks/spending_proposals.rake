namespace :spending_proposals do

  desc "Check if there are any spending proposals in DB"
  task check: :environment do
    if Rails.env.production? && SpendingProposal.any?
      puts "WARNING"
      puts "You have spending proposals in your database."
      puts "This model has been deprecated in favor of budget investments."
      puts "In the next CONSUL release spending proposals will be deleted."
      puts "If you do not need to keep this data, you don't have to do anything else."
      print "If you would like to migrate the data from spending proposals to budget investments "
      puts "please review this PR https://github.com/consul/consul/pull/3431."
    end
  end

  desc "Migrates all necessary data from spending proposals to budget investments"
  task migrate: :environment do
    require "migrations/spending_proposal/budget"
    Migrations::SpendingProposal::Budget.new.migrate
  end

end
