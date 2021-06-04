class Widget::Feeds::BudgetComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end
end
