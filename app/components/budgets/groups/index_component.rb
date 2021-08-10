class Budgets::Groups::IndexComponent < ApplicationComponent
  include Header
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  def title
    t("budgets.groups.show.title")
  end
end
