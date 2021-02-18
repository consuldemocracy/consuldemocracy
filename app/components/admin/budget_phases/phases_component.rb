class Admin::BudgetPhases::PhasesComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def phases
      budget.phases.order(:id)
    end

    def start_date(phase)
      formatted_date(phase.starts_at)
    end

    def end_date(phase)
      formatted_date(phase.ends_at)
    end

    def formatted_date(time)
      l(time.to_date) if time.present?
    end
end
