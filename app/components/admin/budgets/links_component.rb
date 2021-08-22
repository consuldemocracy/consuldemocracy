class Admin::Budgets::LinksComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def action(action_name, **options)
      render Admin::ActionComponent.new(action_name, budget, **options)
    end
end
