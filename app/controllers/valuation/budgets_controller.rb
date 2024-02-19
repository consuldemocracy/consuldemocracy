class Valuation::BudgetsController < Valuation::BaseController
  include FeatureFlags
  feature_flag :budgets

  load_and_authorize_resource

  def index
    @investments_count = {}
    @budgets = @budgets.open.published.valuating
    @budgets.each do |budget|
      @investments_count[budget.id] = budget.investments
                                            .by_valuator(current_user.valuator)
                                            .valuation_open
                                            .count
    end
  end
end
