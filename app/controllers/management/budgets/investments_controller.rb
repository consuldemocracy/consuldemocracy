class Management::Budgets::InvestmentsController < Management::BaseController
  include Translatable
  before_action :load_budget

  load_resource :budget
  load_resource :investment, through: :budget, class: "Budget::Investment"

  before_action :only_verified_users, except: :print

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
      notice = t("flash.actions.create.notice", resource_name: Budget::Investment.model_name.human, count: 1)
      redirect_to management_budget_investment_path(@budget, @investment), notice: notice
    else
      load_categories
      render :new
    end
  end

  def show
    load_investment_votes(@investment)
  end

  def vote
    @investment.register_selection(managed_user, vote_value)
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
      attributes = [:external_url, :heading_id, :tag_list, :organization_name, :location,
                    map_location_attributes: [:latitude, :longitude, :zoom]]
      params.require(:budget_investment).permit(attributes, translation_params(Budget::Investment))
    end

    def only_verified_users
      check_verified_user t("management.budget_investments.alert.unverified_user")
    end

    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:budget_id]
    end

    def load_categories
      @categories = Tag.category.order(:name)
    end

    def vote_value
      params[:value] || "yes"
    end
end
