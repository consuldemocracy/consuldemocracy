class Admin::BudgetsWizard::Budgets::NewComponent < ApplicationComponent
  include Header
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  def title
    t("admin.budgets.new.title")
  end
end
