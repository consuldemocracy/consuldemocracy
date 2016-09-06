class Admin::BudgetInvestmentsController < Admin::BaseController

  before_action :load_budget, only: [:index, :show]

  has_filters %w{valuation_open without_admin managed valuating valuation_finished all}, only: :index

  def index
    @investments = Budget::Investment.scoped_filter(params, @current_filter).order(cached_votes_up: :desc, created_at: :desc).page(params[:page])
  end

  def show
    @investment = Budget::Investment.where(budget_id: @budget.id).find params[:id]
  end

  private

    def load_budget
      @budget = Budget.includes(:groups).find params[:budget_id]
    end

end