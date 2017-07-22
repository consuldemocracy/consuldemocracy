module WelcomeHelper

  def active_class(index)
    "is-active is-in" if index == 0
  end

  def slide_display(index)
    "display: none;" if index > 0
  end

  def recommended_path(recommended)
    case recommended.class.name
    when "Debate"
      debate_path(recommended)
    when "Proposal"
      proposal_path(recommended)
    when "Budget::Investment"
      budget_investment_path(budget_id: recommended.budget.id, id: recommended.id)
    else
      '#'
    end
  end

end
