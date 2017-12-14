namespace :spending_proposals do
  desc "Migrates Existing 2016 Spending Proposals to Budget Investments (PARTIALLY)"
  task export: :migrate_to_budgets do
    puts "We have #{SpendingProposal.count} spending proposals"
    puts "Migrating!!..."
    SpendingProposal.all.each { |sp| MigrateSpendingProposalsToInvestments.new.import(sp) }
    puts "And now we've got #{Budget.where(name: '2016').first.investments.count} budgets"
  end
end
