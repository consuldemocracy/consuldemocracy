module BudgetExecutionsHelper

  def winner_investments(heading)
    if params[:status].present?
      heading.investments
             .selected
             .sort_by_ballots
             .joins(:milestones)
             .distinct
             .where('budget_investment_milestones.status_id = ?', params[:status])
    else
      heading.investments
             .selected
             .sort_by_ballots
             .joins(:milestones)
             .distinct
    end
  end

end
