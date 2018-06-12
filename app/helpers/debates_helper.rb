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

  def debates_minimal_view_path
    debates_path(view: debates_secondary_view)
  end

  def debates_default_view?
    @view == "default"
  end

  def debates_current_view
    @view
  end

  def debates_secondary_view
    debates_current_view == "default" ? "minimal" : "default"
  end

end
