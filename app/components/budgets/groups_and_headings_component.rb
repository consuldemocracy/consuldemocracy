class Budgets::GroupsAndHeadingsComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def heading_name_and_price_html(heading)
      tag.div do
        concat(heading.name + " ")
        concat(tag.span(budget.formatted_heading_price(heading)))
      end
    end
end
