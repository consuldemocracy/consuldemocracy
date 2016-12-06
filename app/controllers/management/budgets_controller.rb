class Management::BudgetsController < Management::BaseController
  include FeatureFlags
  include HasFilters
  feature_flag :budgets

  def create_investments
    @budgets = Budget.accepting.order(created_at: :desc).page(params[:page])
  end

  def support_investments
    @budgets = Budget.accepting.order(created_at: :desc).page(params[:page])
  end

  def print_investments
    @budgets = Budget.current.order(created_at: :desc).page(params[:page])
  end

end
