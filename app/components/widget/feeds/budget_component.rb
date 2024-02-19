class Widget::Feeds::BudgetComponent < ApplicationComponent
  attr_reader :budget
  delegate :image_path_for, to: :helpers

  def initialize(budget)
    @budget = budget
  end
end
