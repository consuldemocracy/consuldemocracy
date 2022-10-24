class Budgets::PhasesComponent < ApplicationComponent
  delegate :wysiwyg, :auto_link_already_sanitized_html, to: :helpers
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def phases
      budget.published_phases
    end

    def start_date(phase)
      time_tag(phase.starts_at.to_date, format: :long) if phase.starts_at.present?
    end

    def end_date(phase)
      time_tag(phase.ends_at.to_date - 1.day, format: :long) if phase.ends_at.present?
    end

    def phase_dom_id(phase)
      "phase-#{phases.index(phase) + 1}-#{phase.name.parameterize}"
    end

    def prev_phase_dom_id(phase)
      phase_dom_id(phases[phases.index(phase) - 1])
    end

    def next_phase_dom_id(phase)
      phase_dom_id(phases[phases.index(phase) + 1])
    end
end
