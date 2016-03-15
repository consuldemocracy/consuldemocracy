namespace :spending_proposals do
  desc "Updates all spending_proposals"
  task touch: :environment do
    SpendingProposal.find_in_batches do |spending_proposal|
      spending_proposal.each(&:save)
    end
  end

end
