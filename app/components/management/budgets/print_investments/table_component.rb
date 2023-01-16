class Management::Budgets::PrintInvestments::TableComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end
end
