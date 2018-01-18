class Valuation::BudgetsController < Valuation::BaseController
  include FeatureFlags
  feature_flag :budgets

  load_and_authorize_resource

  def index
    @budget = current_budget
    if @budget.present?
      @investments_with_valuation_open = {}
      @investments_with_valuation_open = @budget.investments
                                                .by_valuator(current_user.valuator.try(:id))
                                                .valuation_open
                                                .count
    end
  end
end
