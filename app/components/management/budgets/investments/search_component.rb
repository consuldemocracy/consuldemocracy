class Management::Budgets::Investments::SearchComponent < ApplicationComponent
  attr_reader :budget, :url
  use_helpers :budget_heading_select_options

  def initialize(budget, url:)
    @budget = budget
    @url = url
  end
end
