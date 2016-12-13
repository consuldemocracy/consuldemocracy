class Valuation::BudgetsController < Valuation::BaseController
  include FeatureFlags
  feature_flag :budgets

  has_filters %w{current finished}, only: :index

  load_and_authorize_resource

  def index
    @budgets = Budget.send(@current_filter).order(created_at: :desc).page(params[:page])
  end

end
