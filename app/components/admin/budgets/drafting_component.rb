class Admin::Budgets::DraftingComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  def render?
    can?(:publish, budget)
  end
end
