require_dependency Rails.root.join("app", "models", "budget").to_s

class Budget < ApplicationRecord
  has_many :questions, class_name: "Budget::Question"

  CUSTOM_PHASE_ACCEPTING = ["accepting"]
  CUSTOM_PHASE_SELECTING = ["selecting"]
  CUSTOM_PHASE_BALLOTING = ["balloting", "publishing_prices", "valuating"]
  CUSTOM_PHASE_FINISHED = ["finished", "reviewing_ballots"]

  CustomPhase = Struct.new(
    :kind,
    :summary,
    :description,
    :starts_at,
    :ends_at,
    :url,
    :enabled,
    :active,
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
    }.each do |phases, enabled|
      url = nil
      active = phases.include? self.phase
      phase = phases[0]
      if self.phase === "balloting"
        url = budget_investments_url.call(
          self,
          # TODO check with maja
          # heading_id: current_user&.balloted_heading_id ?
          #   current_user&.balloted_heading_id :
          #   self&.headings&.first&.id
        )
      # elsif self.phase === "valuating"
      #   puts "@@@@@@@@@@@@@@"
      #   url = budget_investments_url.call(
      #     self,
      #     heading_id: current_user&.balloted_heading_id ?
      #       current_user&.balloted_heading_id :
      #       self&.headings&.first&.id
      #   )
      else
        url = budget_investments_url.call(self)
      end
      custom_phases[phase] = CustomPhase.new(
        phase,
        self.phases.where(kind: phase).first&.summary,
        self.phases.where(kind: phase).first&.description,
        self.phases.where(kind: phase).first&.starts_at,
        self.phases.where(kind: phase).first&.ends_at,
        url,
        enabled,
        active,
        self.phases.where(kind: phase).first&.presentation_summary_accepting,
        self.phases.where(kind: phase).first&.presentation_summary_balloting,
        self.phases.where(kind: phase).first&.presentation_summary_finished
      )
    end
    custom_phases
  end

  def categories
    Tag.category.order(:name)
  end
end
