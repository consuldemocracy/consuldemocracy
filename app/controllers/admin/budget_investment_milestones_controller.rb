class Admin::BudgetInvestmentMilestonesController < Admin::BaseController

  before_action :load_budget_investment, only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :load_budget_investment_milestone, only: [:edit, :update, :destroy]

  def index
  end

  def new
    @milestone = Budget::Investment::Milestone.new
  end

  def create
    @milestone = Budget::Investment::Milestone.new(milestone_params)
    @milestone.investment = @investment
    if @milestone.save
      redirect_to admin_budget_budget_investment_path(@investment.budget, @investment), notice: t('admin.milestones.create.notice')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @milestone.update(milestone_params)
      redirect_to admin_budget_budget_investment_path(@investment.budget, @investment), notice: t('admin.milestones.update.notice')
    else
      render :edit
    end
  end

  def destroy
    @milestone.destroy
    redirect_to admin_budget_budget_investment_path(@investment.budget, @investment), notice: t('admin.milestones.delete.notice')
  end

  private

  def milestone_params
    params.require(:budget_investment_milestone)
          .permit(:title, :description, :budget_investment_id)
  end

  def load_budget_investment
    @investment = Budget::Investment.find params[:budget_investment_id]
  end

  def load_budget_investment_milestone
    @milestone = Budget::Investment::Milestone.find params[:id]
  end


end
