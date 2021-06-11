class Admin::BudgetsWizard::Budgets::NewComponent < ApplicationComponent
  include Header
  attr_reader :budget
  delegate :single_heading?, to: :helpers

  def initialize(budget)
    @budget = budget
  end

  def title
    if single_heading?
      t("admin.budgets.new.title_single")
    else
      t("admin.budgets.new.title_multiple")
    end
  end
end
