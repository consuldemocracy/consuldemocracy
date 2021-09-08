class Valuation::BudgetsController < Valuation::BaseController
  include FeatureFlags
  feature_flag :budgets

  load_and_authorize_resource

  def index
    @budget = current_budget
    if @budget.present?
      @investments = @budget.investments.by_valuator(current_user.valuator).valuation_open
    end
  end
end
