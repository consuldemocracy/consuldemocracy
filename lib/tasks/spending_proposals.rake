namespace :spending_proposals do

  desc "Migrates all necessary data from spending proposals to budget investments"
  task migrate: :environment do
    require "migrations/spending_proposal/budget"
    Migrations::SpendingProposal::Budget.new.migrate
  end

end
