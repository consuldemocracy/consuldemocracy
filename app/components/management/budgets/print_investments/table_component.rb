class Management::Budgets::PrintInvestments::TableComponent < ApplicationComponent
  attr_reader :budgets
  delegate :paginate, to: :helpers

  def initialize(budgets)
    @budgets = budgets
  end
end
