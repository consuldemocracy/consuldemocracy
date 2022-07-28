class Budgets::GroupsAndHeadingsComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def price(heading)
      tag.span(budget.formatted_heading_price(heading)) if budget.show_money?
    end
end
