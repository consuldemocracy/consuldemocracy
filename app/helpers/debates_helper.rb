module DebatesHelper

  def has_featured?
    Debate.all.featured.count > 0
  end

  def empty_recommended_debates_message_text(user)
    if user.interests.any?
      t('debates.index.recommendations.without_results')
    else
      t('debates.index.recommendations.without_interests')
    end
  end

end
