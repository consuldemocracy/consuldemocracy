class Valuation::BudgetsController < Valuation::BaseController
  include FeatureFlags
  feature_flag :budgets

  load_and_authorize_resource

  def index
    @budgets = @budgets.current.order(created_at: :desc).page(params[:page])
  end

end
