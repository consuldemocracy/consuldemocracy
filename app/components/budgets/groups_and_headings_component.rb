class Budgets::GroupsAndHeadingsComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def price(heading)
      tag.span(budget.formatted_heading_price(heading)) if budget.show_money?
    end

    def heading_name_and_price_html(heading, budget)
      tag.div do
        concat(heading.name + " ")
        if budget.show_money?
          concat(tag.span(budget.formatted_heading_price(heading)))
        end
      end
    end
end
