class Admin::BudgetsController < Admin::BaseController

  has_filters %w{open finished}, only: :index

  def index
    @budgets = Budget.send(@current_filter).order(created_at: :desc).page(params[:page])
  end

end
