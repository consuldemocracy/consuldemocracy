namespace :proposals do
  desc "Updates all proposals by recalculating their hot_score"
  task touch: :environment do
    Proposal.find_in_batches do |proposals|
      proposals.each(&:save)
    end
  end

end
