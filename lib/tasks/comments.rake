namespace :comments do

  desc "Recalculates all the comment counters for debates and proposals"
  task count: :environment do
    Debate.all.pluck(:id).each{ |id| Debate.reset_counters(id, :comments) }
    Proposal.all.pluck(:id).each{ |id| Proposal.reset_counters(id, :comments) }
  end

  desc "Recalculates all the comment confidence scores (used for sorting comments)"
  task confidence_score: :environment do
    Comment.with_hidden.find_in_batches do |comments|
      comments.each(&:save)
    end
  end

end
