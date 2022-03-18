class Management::Budgets::InvestmentsController < Management::BaseController
  include Translatable
  include ImageAttributes
  include DocumentAttributes
  include MapLocationAttributes
  include FeatureFlags
  feature_flag :budgets

  before_action :load_budget

  load_resource :budget
  load_resource :investment, through: :budget, class: "Budget::Investment"

  before_action :only_verified_users, except: :print

  def index
    @investments = @investments.apply_filters_and_search(@budget, params).page(params[:page])
  end

  def new
  end

  def create
    @investment.terms_of_service = "1"
    @investment.author = managed_user
    @investment.heading = @budget.headings.first if @budget.single_heading?

    if @investment.save
      notice = t("flash.actions.create.notice", resource_name: Budget::Investment.model_name.human, count: 1)
      redirect_to management_budget_investment_path(@budget, @investment), notice: notice
    else
      render :new
    end
  end

  def show
  end

  def print
    @investments = @investments.apply_filters_and_search(@budget, params).order(cached_votes_up: :desc).for_render.limit(15)
  end

  private

    def investment_params
      params.require(:budget_investment).permit(allowed_params)
    end

    def allowed_params
      attributes = [:external_url, :heading_id, :tag_list, :organization_name, :location,
                    image_attributes: image_attributes,
                    documents_attributes: document_attributes,
                    map_location_attributes: map_location_attributes]

      [*attributes, translation_params(Budget::Investment)]
    end

    def only_verified_users
      check_verified_user t("management.budget_investments.alert.unverified_user")
    end

    def load_budget
      @budget = Budget.find_by_slug_or_id! params[:budget_id]
    end
end
