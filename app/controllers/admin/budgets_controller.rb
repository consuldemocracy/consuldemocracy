class Admin::BudgetsController < Admin::BaseController

  has_filters %w{open finished}, only: :index

  def index
    @budgets = Budget.send(@current_filter).order(created_at: :desc).page(params[:page])
  end

  def new
    @budget = Budget.new
  end

  def create
    @budget = Budget.new(budget_params)
    if @budget.save
      redirect_to admin_budgets_path, notice: t('admin.budgets.create.notice')
    else
      render :new
    end
  end

  private

    def budget_params
      params.require(:budget).permit(:name, :description, :phase, :currency_symbol)
    end

end
