class ProposalAchievementsQuery
  attr_reader :params

  def self.for(params)
    query = ProposalAchievementsQuery.new params
    query.results
  end

  def initialize(params)
    @params = params
  end

  def results
    grouped_results = groups
    grouped_results.each do |key, achievements|
      grouped_results[key] = []

      achievements.each do |achievement|
        grouped_results[key] << {
          executed_at: achievements.last.executed_at,
          title: achievements.last.proposal_dashboard_action.title
        }
      end
    end

    grouped_results
  end

  private

  def groups
    return achievements.group_by { |v| v.executed_at.to_date.year } if params[:group_by] == 'year'
    return achievements.group_by { |v| "#{v.executed_at.to_date.cweek}/#{v.executed_at.to_date.year}" } if params[:group_by] == 'week'
    return achievements.group_by { |v| "#{v.executed_at.to_date.year}-#{v.executed_at.to_date.month}" } if params[:group_by] == 'month'
    achievements.group_by { |a| a.executed_at.to_date }
  end

  def achievements
    ProposalExecutedDashboardAction
      .includes(:proposal_dashboard_action)
      .where(proposal: proposal, executed_at: start_date.beginning_of_day..end_date.end_of_day)
      .order(executed_at: :asc)
  end

  def proposal
    @proposal ||= Proposal.find(params[:proposal_id])
  end

  def start_date
    return Date.parse(params[:start_date]) unless params[:start_date].blank?
    proposal.created_at.to_date
  end

  def end_date
    return Date.parse(params[:end_date]) unless params[:end_date].blank?
    Date.today
  end
end

