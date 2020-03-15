class Admin::BudgetsWizard::PhasesController < Admin::BudgetsWizard::BaseController
  include Admin::BudgetPhasesActions

  def index
  end

  def update_all
    @budget.update!(phases_params)

    redirect_to admin_budgets_path, notice: t("admin.budgets_wizard.phases.update_all.notice")
  end

  private

    def phases_index
      admin_budgets_wizard_budget_budget_phases_path(@phase.budget, url_params)
    end

    def phases_params
      params.require(:budget).permit(allowed_phases_params)
    end

    def allowed_phases_params
      { phases_attributes: [:id, :enabled] }
    end
end
