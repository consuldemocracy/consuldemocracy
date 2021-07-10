class Budgets::Investments::NewComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end
end
