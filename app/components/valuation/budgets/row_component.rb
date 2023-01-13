class Valuation::Budgets::RowComponent < ApplicationComponent
  attr_reader :budget
  with_collection_parameter :budget

  delegate :current_user, to: :helpers

  def initialize(budget:)
    @budget = budget
  end

  def investments_count
    return 0 unless budget.valuating?

    budget.investments.visible_to_valuators.by_valuator(current_user.valuator).valuation_open.count
  end
end
