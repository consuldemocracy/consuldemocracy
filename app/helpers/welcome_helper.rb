module WelcomeHelper

  def active_class(index)
    "is-active is-in" if index == 0
  end

  def slide_display(index)
    "display: none;" if index > 0
  end

  def recommended_path(recommended)
    case recommended.class
    when Debate
      debates_path(recommended)
    when Proposal
      proposals_path(recommended)
    when Budget::Investment
      budget_investments_path(recommended)
    else
      '#'
    end
  end

  def title_key(key)
    key.gsub("-", "_")
  end

end
