class Admin::BudgetsWizard::Phases::EditComponent < ApplicationComponent
  include Header
  attr_reader :phase

  def initialize(phase)
    @phase = phase
  end

  def budget
    phase.budget
  end

  def title
    "#{t("admin.budget_phases.edit.title")} - #{phase.name}"
  end

  private

    def form_path
      admin_budgets_wizard_budget_budget_phases_path(budget)
    end
end
