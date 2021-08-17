class Admin::Budgets::TableActionsComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def create_budget_poll_path
      balloting_phase = budget.phases.find_by(kind: "balloting")

      admin_polls_path(poll: {
        name:      budget.name,
        budget_id: budget.id,
        starts_at: balloting_phase.starts_at,
        ends_at:   balloting_phase.ends_at
      })
    end
end
