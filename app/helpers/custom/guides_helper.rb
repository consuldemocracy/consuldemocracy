module Custom::GuidesHelper

  def new_proposal_guide
    if feature?('guides') && Budget.current&.accepting?
      new_guide_path
    else
      new_proposal_path
    end
  end

  def new_budget_investment_guide
    if feature?('guides')
      new_guide_path
    else
      new_budget_investment_path(current_budget)
    end
  end

end
