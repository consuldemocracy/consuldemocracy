class Admin::BudgetsController < Admin::BaseController
  include FeatureFlags
  feature_flag :budgets

  has_filters %w{open finished}, only: :index

  load_and_authorize_resource

  def index
    @budgets = Budget.send(@current_filter).order(created_at: :desc).page(params[:page])
  end

  def show
  end

  def new
  end

  def edit
  end

  def calculate_winners
    return unless @budget.balloting_process?
    @budget.headings.each { |heading| Budget::Result.new(@budget, heading).delay.calculate_winners }
    redirect_to admin_budget_budget_investments_path(budget_id: @budget.id, filter: 'winners'),
                notice: I18n.t("admin.budgets.winners.calculated")
  end

  def update
    if @budget.update(budget_params)
      redirect_to admin_budgets_path, notice: t('admin.budgets.update.notice')
    else
      render :edit
    end
  end

  def create
    @budget = Budget.new(budget_params)
    if @budget.save
      redirect_to admin_budget_path(@budget), notice: t('admin.budgets.create.notice')
    else
      render :new
    end
  end

  def destroy
    if @budget.investments.any?
      redirect_to admin_budgets_path, alert: t('admin.budgets.destroy.unable_notice')
    else
      @budget.destroy
      redirect_to admin_budgets_path, notice: t('admin.budgets.destroy.success_notice')
    end
  end

  private

    def budget_params
      descriptions = Budget::Phase::PHASE_KINDS.map{|p| "description_#{p}"}.map(&:to_sym)
      valid_attributes = [:name, :phase, :currency_symbol] + descriptions
      params.require(:budget).permit(*valid_attributes)
    end

end
