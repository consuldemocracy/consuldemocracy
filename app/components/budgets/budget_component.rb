class Budgets::BudgetComponent < ApplicationComponent
  attr_reader :budget
  delegate :attached_background_css, to: :helpers

  def initialize(budget)
    @budget = budget
  end
end
