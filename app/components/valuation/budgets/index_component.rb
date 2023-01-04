class Valuation::Budgets::IndexComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end
end
