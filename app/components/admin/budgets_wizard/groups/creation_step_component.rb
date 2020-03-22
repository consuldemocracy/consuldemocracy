class Admin::BudgetsWizard::Groups::CreationStepComponent < ApplicationComponent
  attr_reader :group, :next_step_group

  def initialize(group, next_step_group)
    @group = group
    @next_step_group = next_step_group
  end

  private

    def budget
      group.budget
    end

    def form_path
      admin_budgets_wizard_budget_groups_path(budget)
    end

    def next_step_path
      admin_budgets_wizard_budget_group_headings_path(budget, next_step_group) if next_step_enabled?
    end

    def next_step_enabled?
      next_step_group.present?
    end
end
