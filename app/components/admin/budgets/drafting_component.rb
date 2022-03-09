class Admin::Budgets::DraftingComponent < ApplicationComponent
  delegate :can?, to: :controller
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  def render?
    can?(:publish, budget)
  end
end
