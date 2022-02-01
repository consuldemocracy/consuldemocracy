class Admin::BudgetPhasesController < Admin::BaseController
  include Admin::BudgetPhasesActions

  private

    def phases_index
      admin_budget_path(@phase.budget)
    end
end
