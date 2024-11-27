class Budgets::GroupsAndHeadingsComponent < ApplicationComponent; end
load Rails.root.join("app", "components", "budgets", "groups_and_headings_component.rb")
class Budgets::GroupsAndHeadingsComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def price(heading)
      tag.span(budget.formatted_heading_price(heading)) if budget.show_money?
    end
end
