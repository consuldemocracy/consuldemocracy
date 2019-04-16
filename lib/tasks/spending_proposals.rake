namespace :spending_proposals do

  desc "Check if there are any spending proposals in DB"
  task check: :environment do
    if !Rails.env.production?
      puts "Please run this rake task in your production environment."
    else
      if SpendingProposal.any?
        puts "WARNING"
        puts "You have spending proposals in your database."
        puts "This model has been deprecated in favor of budget investments."
        puts "In the next CONSUL release spending proposals will be deleted."
        puts "If you do not need to keep this data, you don't have to do anything else."
        print "If you would like to migrate the data from spending proposals to budget investments "
        puts "please check this PR https://github.com/consul/consul/pull/3431."
      else
        puts "All good!"
      end
    end
  end

end
