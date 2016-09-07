class Admin::BudgetInvestmentsController < Admin::BaseController

  before_action :load_budget
  before_action :load_investment, only: [:show, :edit, :update]

  has_filters %w{valuation_open without_admin managed valuating valuation_finished all}, only: :index

  def index
    @investments = Budget::Investment.scoped_filter(params, @current_filter).order(cached_votes_up: :desc, created_at: :desc).page(params[:page])
  end

  def show
  end

  def edit
    load_admins
    load_valuators
    load_tags
  end

   def update
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

  private

    def budget_investment_params
      params.require(:budget_investment).permit(:title, :description, :external_url, :heading_id, :administrator_id, :tag_list, valuator_ids: [])
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
      @tags = ActsAsTaggableOn::Tag.budget_investment_tags
    end
end