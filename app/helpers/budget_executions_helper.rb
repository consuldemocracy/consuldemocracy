module BudgetExecutionsHelper

  def winner_investments(heading)
    if params[:status].present?
      heading.investments
             .winners
             .joins(:milestones)
             .distinct
             .where('budget_investment_milestones.status_id = ?', params[:status])
    else
      heading.investments
             .winners
             .joins(:milestones)
             .distinct
    end
  end

end
