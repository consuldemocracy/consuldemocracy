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
      formatted_date(phase.starts_at) if phase.starts_at.present?
    end

    def end_date(phase)
      formatted_date(phase.ends_at - 1.second) if phase.ends_at.present?
    end

    def formatted_date(time)
      time_tag(time, format: :datetime)
    end
end
