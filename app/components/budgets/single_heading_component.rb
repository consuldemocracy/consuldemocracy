class Budgets::SingleHeadingComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def heading
      budget.headings.first
    end

    def title
      heading.name
    end

    def price
      budget.formatted_heading_price(heading)
    end
end
