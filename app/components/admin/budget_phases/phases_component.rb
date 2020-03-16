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
end
