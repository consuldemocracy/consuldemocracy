class Admin::BudgetsWizard::Groups::EditComponent < ApplicationComponent
  include Header
  attr_reader :group

  def initialize(group)
    @group = group
  end

  def budget
    group.budget
  end

  def title
    budget.name
  end

  private

    def form_path
      admin_budgets_wizard_budget_group_path(budget, group)
    end
end
