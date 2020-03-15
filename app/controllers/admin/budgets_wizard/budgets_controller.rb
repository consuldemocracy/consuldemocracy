class Admin::BudgetsWizard::BudgetsController < Admin::BaseController
  include Translatable
  include FeatureFlags
  feature_flag :budgets

  load_and_authorize_resource

  def new
  end

  def create
    @budget.published = false

    if @budget.save
      redirect_to edit_admin_budget_path(@budget), notice: t("admin.budgets.create.notice")
    else
      render :new
    end
  end

  private

    def budget_params
      params.require(:budget).permit(*allowed_params)
    end

    def allowed_params
      valid_attributes = [:currency_symbol, :voting_style, administrator_ids: [], valuator_ids: []]

      valid_attributes + [translation_params(Budget)]
    end
end
