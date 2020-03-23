class Admin::BudgetsWizard::PhasesController < Admin::BaseController
  include Admin::BudgetPhasesActions

  def index
  end

  private

    def phases_index
      admin_budgets_wizard_budget_budget_phases_path(@phase.budget)
    end
end
