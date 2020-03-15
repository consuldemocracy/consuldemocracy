class Admin::BudgetsWizard::BudgetsController < Admin::BaseController
  include Translatable
  include ImageAttributes
  include FeatureFlags
  feature_flag :budgets

  load_and_authorize_resource

  helper_method :budget_mode, :single_heading?

  def new
  end

  def edit
  end

  def create
    @budget.published = false

    if @budget.save
      redirect_to groups_index, notice: t("admin.budgets.create.notice")
    else
      render :new
    end
  end

  def update
    if @budget.update(budget_params)
      redirect_to groups_index, notice: t("admin.budgets.update.notice")
    else
      render :edit
    end
  end

  private

    def budget_params
      params.require(:budget).permit(*allowed_params)
    end

    def allowed_params
      valid_attributes = [:currency_symbol, :voting_style, administrator_ids: [], valuator_ids: [],
                          image_attributes: image_attributes]

      valid_attributes + [translation_params(Budget)]
    end

    def groups_index
      admin_budgets_wizard_budget_groups_path(@budget, url_params)
    end

    def budget_mode
      params[:mode]
    end

    def single_heading?
      budget_mode == "single"
    end

    def url_params
      budget_mode.present? ? { mode: budget_mode } : {}
    end
end
