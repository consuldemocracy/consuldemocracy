class Valuation::BudgetsController < Valuation::BaseController
  include FeatureFlags
  feature_flag :budgets

  load_and_authorize_resource

  def index
    @budget = current_budget
  end
end
