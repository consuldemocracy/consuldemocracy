class Admin::Budgets::ActionsComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end
end
