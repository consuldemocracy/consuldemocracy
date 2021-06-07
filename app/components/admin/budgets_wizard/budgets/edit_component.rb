class Admin::BudgetsWizard::Budgets::EditComponent < ApplicationComponent
  include Header
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  def title
    t("admin.budgets.edit.title")
  end
end
