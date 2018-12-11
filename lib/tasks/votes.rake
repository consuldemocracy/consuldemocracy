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

  desc "Resets hot_score to its new value"
  task reset_hot_score: :environment do
    models = [Debate, Proposal, Legislation::Proposal]

    models.each do |model|
      model.find_each do |resource|
        resource.save
        print "."
      end
    end
  end
end
