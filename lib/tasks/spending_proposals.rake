namespace :spending_proposals do
  desc "Migrates Existing 2016 Spending Proposals to Budget Investments (PARTIALLY)"
  task migrate_to_budgets: :environment do
    puts "We have #{SpendingProposal.count} spending proposals"
    puts "Migrating!!..."
    SpendingProposal.all.each { |sp| MigrateSpendingProposalsToInvestments.new.import(sp) }
    puts "And now we've got #{Budget.where(name: '2016').first.investments.count} budgets"
  end

  desc "Migrates winner Spending Proposals to their existing Budget Investments"
  task migrate_winner_spending_proposals: :environment do
    delegated_ballots = Forum.delegated_ballots
    winner_spending_proposals = []

    [nil, Geozone.all].flatten.each do |geozone|

      available_budget = Ballot.initial_budget(geozone).to_i
      spending_proposals = SpendingProposal.feasible.compatible.valuation_finished
                                           .by_geozone(geozone.try(:id))
      spending_proposals = SpendingProposal.sort_by_delegated_ballots_and_price(spending_proposals,
                                                                               delegated_ballots)

      spending_proposals.each do |spending_proposal|
        initial_budget = available_budget
        budget = available_budget - spending_proposal.price
        available_budget = budget if budget >= 0

        winner_spending_proposals << spending_proposal.id if budget >= 0

      end
    end

    Budget::Investment.where(original_spending_proposal_id: winner_spending_proposals)
                      .update_all(winner: true, selected: true)
  end
end
