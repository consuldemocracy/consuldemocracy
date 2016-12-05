class Management::Budgets::InvestmentsController < Management::BaseController

  before_action :only_verified_users, except: :print
  before_action :set_budget_investment, only: [:vote, :show]
  before_action :load_accepting_headings, only: [:new, :create]

  def index
    @investments = apply_filters_and_search(Budget::Investment).order(cached_votes_up: :desc).page(params[:page]).for_render
    @investment_ids = @investments.pluck(:id)
    set_investment_ballots(@investments)
    set_budget_investment_votes(@investments)
  end

  def new
    @investment = Budget::Investment.new
  end

  def create
    @investment = Budget::Investment.new(budget_investment_params)
    @investment.terms_of_service = "1"
    @investment.author = managed_user

    if @investment.save
      redirect_to management_budgets_investment_path(@investment), notice: t('flash.actions.create.notice', resource_name: Budget::Investment.model_name.human, count: 1)
    else
      render :new
    end
  end

  def show
    set_investment_ballots(@investment)
    set_budget_investment_votes(@investment)
  end

  def vote
    @investment.register_vote(managed_user, 'yes')
    set_investment_ballots(@investment)
    set_budget_investment_votes(@investment)
  end

  def print
    params[:geozone] ||= 'all'
    @investments = apply_filters_and_search(Budget::Investment).order(cached_votes_up: :desc).for_render.limit(15)
    set_budget_investment_votes(@investments)
  end

  private

    def set_investment_ballots(investments)
      @investment_ballots = {}
      Budget.where(id: Array.wrap(investments).map(&:budget_id).uniq).each do |budget|
        @investment_ballots[budget] = Budget::Ballot.where(user: current_user, budget: budget).first_or_create
      end
    end

    def set_budget_investment
      @investment = Budget::Investment.find(params[:id])
    end

    def budget_investment_params
      params.require(:budget_investment).permit(:title, :description, :external_url, :geozone_id, :heading_id)
    end

    def only_verified_users
      check_verified_user t("management.budget_investments.alert.unverified_user")
    end

    # This should not be necessary. Maybe we could create a specific show view for managers.
    def set_budget_investment_votes(budget_investments)
      @investment_votes = managed_user ? managed_user.budget_investment_votes(budget_investments) : {}
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

    def load_accepting_headings
      accepting_budget_ids = Budget.accepting.pluck(:id)
      accepting_budget_group_ids = Budget::Group.where(budget_id: accepting_budget_ids).pluck(:id)
      @headings = Budget::Heading.where(group_id: accepting_budget_group_ids).order(:group_id, :name).includes(:group => :budget)
    end

end
