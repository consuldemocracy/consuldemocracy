class Admin::Budgets::IndexComponent < ApplicationComponent
  include Header
  attr_reader :budgets

  def initialize(budgets)
    @budgets = budgets
  end

  def title
    t("admin.budgets.index.title")
  end
end
