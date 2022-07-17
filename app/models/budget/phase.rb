class Budget
  class Phase < ApplicationRecord
    PHASE_KINDS = %w[informing accepting reviewing selecting valuating publishing_prices balloting
                reviewing_ballots finished].freeze
    PUBLISHED_PRICES_PHASES = %w[publishing_prices balloting reviewing_ballots finished].freeze
    DESCRIPTION_MAX_LENGTH = 2000

    translates :name, touch: true
    translates :summary, touch: true
    translates :description, touch: true
    translates :main_link_text, touch: true
    translates :main_link_url, touch: true
    include Globalizable
    include Sanitizable
    include Imageable

    belongs_to :budget, touch: true
    belongs_to :next_phase, class_name: name, inverse_of: :prev_phase
    has_one :prev_phase, class_name: name, foreign_key: :next_phase_id, inverse_of: :next_phase

    validates_translation :name, presence: true
    validates_translation :description, length: { maximum: ->(*) { DESCRIPTION_MAX_LENGTH }}
    validates_translation :main_link_url, presence: true, unless: -> { main_link_text.blank? }
    validates :budget, presence: true
    validates :kind, presence: true, uniqueness: { scope: :budget }, inclusion: { in: PHASE_KINDS }
    validates :starts_at, presence: true
    validates :ends_at, presence: true
    validate :invalid_dates_range?

    scope :enabled,           -> { where(enabled: true) }
    scope :published,         -> { enabled.where.not(kind: "drafting") }

    PHASE_KINDS.each do |phase|
      define_singleton_method(phase) { find_by(kind: phase) }
    end

    def self.kind_or_later(phase)
      PHASE_KINDS[PHASE_KINDS.index(phase)..-1]
    end

    def next_enabled_phase
      next_phase&.enabled? ? next_phase : next_phase&.next_enabled_phase
    end

    def prev_enabled_phase
      prev_phase&.enabled? ? prev_phase : prev_phase&.prev_enabled_phase
    end

    def invalid_dates_range?
      if starts_at.present? && ends_at.present? && starts_at >= ends_at
        errors.add(:starts_at, I18n.t("budgets.phases.errors.dates_range_invalid"))
      end
    end

    def valuating_or_later?
      in_phase_or_later?("valuating")
    end

    def publishing_prices_or_later?
      in_phase_or_later?("publishing_prices")
    end

    def balloting_or_later?
      in_phase_or_later?("balloting")
    end

    def current?
      budget.current_phase == self
    end

    private

      def in_phase_or_later?(phase)
        self.class.kind_or_later(phase).include?(kind)
      end
  end
end
