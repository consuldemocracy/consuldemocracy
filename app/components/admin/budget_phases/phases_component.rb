class Admin::BudgetPhases::PhasesComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def phases
      budget.phases.order(:id)
    end

    def dates(phase)
      Admin::Budgets::DurationComponent.new(phase).dates
    end

    def enabled_text(phase)
      if phase.enabled?
        tag.span t("shared.yes"), class: "budget-phase-enabled"
      else
        tag.span t("shared.no"), class: "budget-phase-disabled"
      end
    end
end
