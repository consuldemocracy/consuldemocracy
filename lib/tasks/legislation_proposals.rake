namespace :legislation_proposals do
  desc "Calculate cached votes score for existing legislation proposals"
  task calculate_cached_votes_score: :environment do
    Legislation::Proposal.find_each do |p|
      p.update_column(:cached_votes_score, p.cached_votes_up - p.cached_votes_down)
      print "."
    end
    puts "\nTask finished 🎉"
  end
end
