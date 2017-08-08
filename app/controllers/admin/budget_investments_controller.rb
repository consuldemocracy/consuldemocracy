class Admin::BudgetInvestmentsController < Admin::BaseController
  include FeatureFlags
  feature_flag :budgets

  has_filters(%w{valuation_open without_admin managed valuating valuation_finished
                 valuation_finished_feasible selected winners all},
              only: [:index, :toggle_selection])

  before_action :load_budget
  before_action :load_investment, only: [:show, :edit, :update, :toggle_selection]
  before_action :load_ballot, only: [:show, :index]
  before_action :load_investments, only: [:index, :toggle_selection]

  def index
  end

  def show
  end

  def edit
    load_admins
    load_valuators
    load_tags
  end

  def update
    set_valuation_tags
    if @investment.update(budget_investment_params)
      redirect_to admin_budget_budget_investment_path(@budget, @investment, Budget::Investment.filter_params(params)),
                  notice: t("flash.actions.update.budget_investment")
    else
      load_admins
      load_valuators
      load_tags
      render :edit
    end
  end

  def toggle_selection
    @investment.toggle :selected
    @investment.save
  end

  private

    def load_investments
      @investments = Budget::Investment.scoped_filter(params, @current_filter)
                                       .order(cached_votes_up: :desc, created_at: :desc)
                                       .page(params[:page])
    end

    def budget_investment_params
      params.require(:budget_investment)
            .permit(:title, :description, :external_url, :heading_id, :administrator_id, :valuation_tag_list, :incompatible,
                    :selected, valuator_ids: [])
    end

    def load_budget
      @budget = Budget.includes(:groups).find params[:budget_id]
    end

    def load_investment
      @investment = Budget::Investment.where(budget_id: @budget.id).find params[:id]
    end

    def load_admins
      @admins = Administrator.includes(:user).all
    end

    def load_valuators
      @valuators = Valuator.includes(:user).all.order("description ASC").order("users.email ASC")
    end

    def load_tags
      @tags = Budget::Investment.tags_on(:valuation).order(:name).uniq
    end

    def load_ballot
      query = Budget::Ballot.where(user: current_user, budget: @budget)
      @ballot = @budget.balloting? ? query.first_or_create : query.first_or_initialize
    end

    def set_valuation_tags
      @investment.set_tag_list_on(:valuation, budget_investment_params[:valuation_tag_list])
      params[:budget_investment] = params[:budget_investment].except(:valuation_tag_list)
    end
end
