class Tracking::BudgetInvestmentProgressBarsController < Tracking::ProgressBarsController

  before_action :restrict_access_to_assigned_items

  private

    def progressable
      Budget::Investment.find(params[:budget_investment_id])
    end

    def restrict_access_to_assigned_items
      return if current_user.administrator? ||
        Budget::TrackerAssignment.exists?(investment_id: params[:budget_investment_id],
                                          tracker_id: current_user.tracker.id)
      raise ActionController::RoutingError.new("Not Found")
    end
end
