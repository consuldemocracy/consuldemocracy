namespace :votes do

  desc "Resets cached_votes_up counter to its latest value"
  task reset_vote_counter: :environment do
    models = [Proposal, Budget::Investment]

    models.each do |model|
      model.find_each do |resource|
        resource.update_cached_votes
        print "."
      end
    end

  end

end
