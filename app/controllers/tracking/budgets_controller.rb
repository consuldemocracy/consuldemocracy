class Tracking::BudgetsController < Tracking::BaseController
  include FeatureFlags
  feature_flag :budgets

  load_and_authorize_resource

  def index
    @budget = current_budget
    if @budget.present?
      @investments = @budget.investments
                            .by_tracker(current_user.tracker)
    end
  end
end
