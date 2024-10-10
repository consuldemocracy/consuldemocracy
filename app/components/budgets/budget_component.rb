class Budgets::BudgetComponent < ApplicationComponent
  attr_reader :budget
  use_helpers :attached_background_css

  def initialize(budget)
    @budget = budget
  end
end
