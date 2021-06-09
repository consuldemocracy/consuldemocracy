class Admin::BudgetsWizard::Phases::IndexComponent < ApplicationComponent
  include Header
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  def title
    t("admin.budget_phases.index.title", budget: budget.name)
  end

  private

    def back_link_path
      admin_budgets_wizard_budget_group_headings_path(budget, budget.groups.first)
    end
end
