class Admin::BudgetInvestmentMilestonesController < Admin::BaseController
  include Translatable

  before_action :load_budget_investment, only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :load_budget_investment_milestone, only: [:edit, :update, :destroy]
  before_action :load_statuses, only: [:index, :new, :create, :edit, :update]

  def index
  end

  def new
    @milestone = Budget::Investment::Milestone.new
  end

  def create
    @milestone = Budget::Investment::Milestone.new(milestone_params)
    @milestone.investment = @investment
    if @milestone.save
      redirect_to admin_budget_budget_investment_path(@investment.budget, @investment),
                  notice: t('admin.milestones.create.notice')
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @milestone.update(milestone_params)
      redirect_to admin_budget_budget_investment_path(@investment.budget, @investment),
                  notice: t('admin.milestones.update.notice')
    else
      render :edit
    end
  end

  def destroy
    @milestone.destroy
    redirect_to admin_budget_budget_investment_path(@investment.budget, @investment),
                notice: t('admin.milestones.delete.notice')
  end

  private

  def milestone_params
    image_attributes = [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy]
    documents_attributes = [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy]
    attributes = [:title, :description, :publication_date, :budget_investment_id, :status_id,
                  *translation_params(Budget::Investment::Milestone),
                  image_attributes: image_attributes, documents_attributes: documents_attributes]

    params.require(:budget_investment_milestone).permit(*attributes)
  end

  def load_budget_investment
    @investment = Budget::Investment.find(params[:budget_investment_id])
  end

  def load_budget_investment_milestone
    @milestone = get_milestone
  end

  def get_milestone
    Budget::Investment::Milestone.find(params[:id])
  end

  def resource
    get_milestone
  end

  def load_statuses
    @statuses = Budget::Investment::Status.all
  end

end
