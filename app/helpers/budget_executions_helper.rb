module BudgetExecutionsHelper

  def winner_investments(heading)
    if params[:status].present?
      heading.investments
             .winners
             .joins(:milestones)
             .distinct
             .where(filter_investment_by_latest_milestone, params[:status])
    else
      heading.investments
             .winners
             .joins(:milestones)
             .distinct
    end
  end

  def filter_investment_by_latest_milestone
    <<-SQL
      (SELECT status_id FROM budget_investment_milestones
       WHERE investment_id = budget_investments.id ORDER BY publication_date DESC LIMIT 1) = ?
    SQL
  end

end
