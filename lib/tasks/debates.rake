namespace :debates do
  desc "Updates all debates by recalculating their hot_score"
  task hot_score: :environment do
    Debate.find_in_batches do |debates|
      debates.each(&:save)
    end
  end

end
