class Dashboard::AchievementsController < Dashboard::BaseController
  include Dashboard::ExpectsDateRange

  def index
    authorize! :dashboard, proposal
    render json: processed_groups
  end

  private

    def processed_groups
      grouped_results = groups
      grouped_results.each do |key, results|
        grouped_results[key] = {
          executed_at: results.last.executed_at,
          title: results.last.action.title
        }
      end

      grouped_results
    end

    def groups
      if params[:group_by] == "week"
        executed_proposed_actions.group_by do |v|
          "#{v.executed_at.to_date.cweek}/#{v.executed_at.to_date.year}"
        end
      elsif params[:group_by] == "month"
        executed_proposed_actions.group_by do |v|
          "#{v.executed_at.to_date.year}-#{v.executed_at.to_date.month}"
        end
      else
        executed_proposed_actions.group_by { |a| a.executed_at.to_date }
      end
    end

    def executed_proposed_actions
      @executed_proposed_actions ||=
        Dashboard::ExecutedAction
        .joins(:action)
        .includes(:action)
        .where(proposal: proposal)
        .where(executed_at: start_date.beginning_of_day..end_date.end_of_day)
        .where(dashboard_actions: { action_type: 0 })
        .order(executed_at: :asc)
    end
end
