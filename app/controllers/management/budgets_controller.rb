class Management::BudgetsController < Management::BaseController
  include FeatureFlags
  feature_flag :budgets

  has_filters %w{open finished}, only: :index

  load_and_authorize_resource

  def index
    @budgets = @budgets.send(@current_filter).order(created_at: :desc).page(params[:page])
  end

  def show
    @budget = Budget.includes(groups: :headings).find(params[:id])
  end
end
