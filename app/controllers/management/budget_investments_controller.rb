class Management::BudgetInvestmentsController < Management::BaseController

  before_action :only_verified_users, except: :print
  before_action :set_budget_investment, only: [:vote, :show]

  def index
    @budget_investments = apply_filters_and_search(Budget::Investment).order(cached_votes_up: :desc).page(params[:page]).for_render
    set_budget_investment_votes(@budget_investments)
  end

  def new
    @investment = Budget::Investment.new
  end

  def create
    @budget_investment = Budget::Investment.new(budget_investment_params)
    @budget_investment.author = managed_user

    if @budget_investment.save
      redirect_to management_budget_investment_path(@budget_investment), notice: t('flash.actions.create.notice', resource_name: t("activerecord.models.budget_investment", count: 1))
    else
      render :new
    end
  end

  def show
    set_budget_investment_votes(@budget_investment)
  end

  def vote
    @budget_investment.register_vote(managed_user, 'yes')
    set_budget_investment_votes(@budget_investment)
  end

  def print
    params[:geozone] ||= 'all'
    @budget_investments = apply_filters_and_search(Budget::Investment).order(cached_votes_up: :desc).for_render.limit(15)
    set_budget_investment_votes(@budget_investments)
  end

  private

    def set_budget_investment
      @budget_investment = Budget::Investment.find(params[:id])
    end

    def budget_investment_params
      params.require(:budget_investment).permit(:title, :description, :external_url, :geozone_id, :terms_of_service)
    end

    def only_verified_users
      check_verified_user t("management.budget_investments.alert.unverified_user")
    end

    # This should not be necessary. Maybe we could create a specific show view for managers.
    def set_budget_investment_votes(budget_investments)
      @budget_investment_votes = managed_user ? managed_user.budget_investment_votes(budget_investments) : {}
    end

    def set_geozone_name
      if params[:geozone] == 'all'
        @geozone_name = t('geozones.none')
      else
        @geozone_name = Geozone.find(params[:geozone]).name
      end
    end

    def apply_filters_and_search(target)
      target = params[:unfeasible].present? ? target.unfeasible : target.not_unfeasible
      if params[:geozone].present?
        target = target.by_geozone(params[:geozone])
        set_geozone_name
      end
      target = target.search(params[:search]) if params[:search].present?
      target
    end

end
