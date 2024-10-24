class Admin::Budgets::GroupsAndHeadingsComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def action(...)
      render Admin::ActionComponent.new(...)
    end
end
