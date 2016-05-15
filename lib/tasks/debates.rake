namespace :debates do
  desc "Updates all debates by recalculating their hot_score"
  task touch: :environment do
    Debate.find_in_batches do |debates|
      debates.each(&:save)
    end
  end

  desc "Updates comment kind of all debates"
  task set_comment_kind: :environment do
    Debate.find_in_batches do |debates|
      debates.each do |debate|
        debate.update(comment_kind: 'comment')
      end
    end
  end

end
