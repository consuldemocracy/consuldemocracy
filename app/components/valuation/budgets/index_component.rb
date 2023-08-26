class Valuation::Budgets::IndexComponent < ApplicationComponent
  attr_reader :budgets

  def initialize(budgets)
    @budgets = budgets
  end
end
