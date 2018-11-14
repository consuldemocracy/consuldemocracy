class Admin::BudgetInvestmentMilestonesController < Admin::BaseController
  include Translatable

  before_action :load_budget_investment, only: [:index, :new, :create, :edit, :update, :destroy]
  before_action :load_milestone, only: [:edit, :update, :destroy]
  before_action :load_statuses, only: [:index, :new, :create, :edit, :update]

  def index
  end

  def new
    @milestone = Milestone.new
  end

  def create
    @milestone = Milestone.new(milestone_params)
    @milestone.milestoneable = @investment
    if @milestone.save
      investment_id = @investment.original_spending_proposal_id || @investment.id
      redirect_to admin_budget_budget_investment_path(budget_id: @investment.budget, id: investment_id),
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
    attributes = [:publication_date, :budget_investment_id, :status_id,
                  translation_params(Milestone),
                  image_attributes: image_attributes, documents_attributes: documents_attributes]

    params.require(:milestone).permit(*attributes)
  end

  def load_budget_investment
    @investment = Budget::Investment.find(params[:budget_investment_id])
  end

  def load_milestone
    @milestone = get_milestone
  end

  def get_milestone
    Milestone.find(params[:id])
  end

  def load_statuses
    @statuses = Milestone::Status.all
  end

  def resource
    get_milestone
  end
end
