class Admin::Budgets::TableActionsComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def actions_component
      Admin::TableActionsComponent.new(
        budget,
        edit_path: admin_budget_path(budget),
        actions: [:edit]
      )
    end
end
