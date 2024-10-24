class Admin::Budgets::ShowComponent < ApplicationComponent
  include Header
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def title
      budget.name
    end
end
