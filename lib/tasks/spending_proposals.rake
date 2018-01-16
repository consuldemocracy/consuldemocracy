namespace :spending_proposals do
  desc "Migrates Existing 2016 Spending Proposals to Budget Investments (PARTIALLY)"
  task migrate_to_budgets: :environment do
    puts "We have #{SpendingProposal.count} spending proposals"
    puts "Migrating!!..."
    SpendingProposal.all.each { |sp| MigrateSpendingProposalsToInvestments.new.import(sp) }
    puts "And now we've got #{Budget.where(name: '2016').first.investments.count} budgets"
  end
end
