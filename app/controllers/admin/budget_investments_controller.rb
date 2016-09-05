class Admin::BudgetInvestmentsController < Admin::BaseController

  has_filters %w{valuation_open without_admin managed valuating valuation_finished all}, only: :index

  def index
    @budget = Budget.includes(:groups).find params[:budget_id]
    @investments = @budget.investments.scoped_filter(params, @current_filter).order(cached_votes_up: :desc, created_at: :desc).page(params[:page])
  end

  def show
    @budget = Budget.includes(:groups).find params[:budget_id]
    @investment = @budget.investments.find params[:id]
  end

end