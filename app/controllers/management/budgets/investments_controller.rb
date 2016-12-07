class Management::Budgets::InvestmentsController < Management::BaseController

  load_and_authorize_resource :budget
  load_and_authorize_resource :investment, through: :budget, class: 'Budget::Investment'

  before_action :only_verified_users, except: :print

  def index
    @investments = apply_filters_and_search(@investments).page(params[:page])
    set_investment_votes(@investments)
  end

  def new
  end

  def create
    @investment.terms_of_service = "1"
    @investment.author = managed_user

    if @investment.save
      notice= t('flash.actions.create.notice', resource_name: Budget::Investment.model_name.human, count: 1)
      redirect_to management_budget_investment_path(@budget, @investment), notice: notice
    else
      render :new
    end
  end

  def show
    set_investment_votes(@investment)
  end

  def vote
    @investment.register_selection(managed_user)
    set_investment_votes(@investment)
  end

  def print
    params[:geozone] ||= 'all'
    @investments = apply_filters_and_search(@investments).order(cached_votes_up: :desc).for_render.limit(15)
  end

  private

    def set_investment_votes(investments)
      @investment_votes = managed_user ? managed_user.budget_investment_votes(investments) : {}
    end

    def load_budget
      @budget = Budget.find(params[:budget_id])
    end

    def investment_params
      params.require(:budget_investment).permit(:title, :description, :external_url, :geozone_id, :heading_id)
    end

    def only_verified_users
      check_verified_user t("management.budget_investments.alert.unverified_user")
    end

    def set_geozone_name
      if params[:geozone] == 'all'
        @geozone_name = t('geozones.none')
      else
        @geozone_name = Geozone.find(params[:geozone]).name
      end
    end

    def apply_filters_and_search(investments)
      investments = params[:unfeasible].present? ? investments.unfeasible : investments.not_unfeasible
      if params[:geozone].present?
        investments = investments.by_geozone(params[:geozone])
        set_geozone_name
      end
      investments = investments.search(params[:search]) if params[:search].present?
      investments
    end

end
