class Admin::Budgets::TableActionsComponent < ApplicationComponent
  include TableActionLink
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def link_to_create_budget_poll
      balloting_phase = budget.phases.find_by(kind: "balloting")

      link_to t("admin.budgets.index.admin_ballots"),
        admin_polls_path(poll: {
          name:      budget.name,
          budget_id: budget.id,
          starts_at: balloting_phase.starts_at,
          ends_at:   balloting_phase.ends_at
        }),
        class: "ballots-link",
        method: :post
    end
end
