class Management::Budgets::PrintInvestments::TableComponent < ApplicationComponent
  attr_reader :budgets
  use_helpers :paginate

  def initialize(budgets)
    @budgets = budgets
  end
end
