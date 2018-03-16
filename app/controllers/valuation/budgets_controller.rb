class Valuation::BudgetsController < Valuation::BaseController
  include FeatureFlags
  feature_flag :budgets

  load_and_authorize_resource

  def index
    @budget = current_budget
    valuator = current_user.valuator
    if @budget.present? && valuator.present?
      @assigned_investments_count = @budget.investments.accesible_by_valuator(valuator)
                                           .valuation_open.count
    end
  end
end
