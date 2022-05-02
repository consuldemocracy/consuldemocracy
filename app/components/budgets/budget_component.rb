class Budgets::BudgetComponent < ApplicationComponent
  delegate :wysiwyg, :auto_link_already_sanitized_html, to: :helpers
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end
end
