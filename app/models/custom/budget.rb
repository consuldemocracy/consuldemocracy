require_dependency Rails.root.join("app", "models", "budget").to_s

class Budget < ApplicationRecord
  has_many :questions, class_name: "Budget::Question"

  CUSTOM_PHASE_ACCEPTING = :accepting
  CUSTOM_PHASE_SELECTING = :selecting
  CUSTOM_PHASE_BALLOTING = :balloting
  CUSTOM_PHASE_FINISHED = :finished

  CustomPhase = Struct.new(
    :kind,
    :summary,
    :description,
    :starts_at,
    :ends_at,
    :url,
    :enabled,
    :presentation_summary_accepting,
    :presentation_summary_balloting,
    :presentation_summary_finished
  ) do
  end

  def self.current
    where.not(phase: :drafting).order(:created_at).last
  end

  def custom_phases(current_user, budget_investments_url)
    custom_phases = {}
    {
      CUSTOM_PHASE_ACCEPTING => true,
      CUSTOM_PHASE_SELECTING => self.phases.selecting.enabled?,
      CUSTOM_PHASE_BALLOTING => true,
      CUSTOM_PHASE_FINISHED => true
    }.each do |phase, enabled|
      url = nil
      if self.phase === phase.to_s
        if self.phase === "balloting"
          url = budget_investments_url.call(
            self,
            heading_id: current_user&.balloted_heading_id ?
              current_user&.balloted_heading_id :
              self&.headings&.first&.id
          )
        else
          url = budget_investments_url.call(self)
        end
      end
      custom_phases[phase] = CustomPhase.new(
        phase,
        current_phase&.summary,
        current_phase&.description,
        current_phase&.starts_at,
        current_phase&.ends_at,
        url,
        enabled,
        current_phase&.presentation_summary_accepting,
        current_phase&.presentation_summary_balloting,
        current_phase&.presentation_summary_finished
      )
    end
    custom_phases
  end
end
