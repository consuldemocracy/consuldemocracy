class Management::Budgets::InvestmentsController < Management::BaseController

  load_resource :budget
  load_resource :investment, through: :budget, class: 'Budget::Investment'

  before_action :only_verified_users, except: :print
  before_action :load_heading, only: [:index, :show, :print]

  def index
    @investments = @investments.apply_filters_and_search(@budget, params).page(params[:page])
    load_investment_votes(@investments)
  end

  def new
    load_categories
  end

  def create
    @investment.terms_of_service = "1"
    @investment.author = managed_user

    if @investment.save
      notice = t('flash.actions.create.notice', resource_name: Budget::Investment.model_name.human, count: 1)
      redirect_to management_budget_investment_path(@budget, @investment), notice: notice
    else
      render :new
    end
  end

  def show
    load_investment_votes(@investment)
  end

  def vote
    @investment.register_selection(managed_user)
    load_investment_votes(@investment)
    respond_to do |format|
      format.html { redirect_to management_budget_investments_path(heading_id: @investment.heading.id) }
      format.js
    end
  end

  def print
    @investments = @investments.apply_filters_and_search(@budget, params).order(cached_votes_up: :desc).for_render.limit(15)
    load_investment_votes(@investments)
  end

  private

    def load_investment_votes(investments)
      @investment_votes = managed_user ? managed_user.budget_investment_votes(investments) : {}
    end

    def investment_params
      params.require(:budget_investment).permit(:title, :description, :external_url, :heading_id, :tag_list, :organization_name, :location)
    end

    def only_verified_users
      check_verified_user t("management.budget_investments.alert.unverified_user")
    end

    def load_heading
      @heading = @budget.headings.find(params[:heading_id]) if params[:heading_id].present?
    end

    def load_categories
      @categories = ActsAsTaggableOn::Tag.category.order(:name)
    end

end
