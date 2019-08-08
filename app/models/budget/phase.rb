class Budget
  class Phase < ApplicationRecord
    PHASE_KINDS = %w(drafting informing accepting reviewing selecting valuating publishing_prices balloting
                reviewing_ballots finished).freeze
    PUBLISHED_PRICES_PHASES = %w(publishing_prices balloting reviewing_ballots finished).freeze
    SUMMARY_MAX_LENGTH = 1000
    DESCRIPTION_MAX_LENGTH = 2000

    translates :summary, touch: true
    translates :description, touch: true
    include Globalizable

    class Translation
      before_validation :sanitize_description

      private

        def sanitize_description
          self.description = WYSIWYGSanitizer.new.sanitize(description)
        end
    end

    include Sanitizable

    belongs_to :budget
    belongs_to :next_phase, class_name: "Budget::Phase", foreign_key: :next_phase_id
    has_one :prev_phase, class_name: "Budget::Phase", foreign_key: :next_phase_id

    validates_translation :summary, length: { maximum: SUMMARY_MAX_LENGTH }
    validates_translation :description, length: { maximum: DESCRIPTION_MAX_LENGTH }
    validates :budget, presence: true
    validates :kind, presence: true, uniqueness: { scope: :budget }, inclusion: { in: PHASE_KINDS }
    validate :invalid_dates_range?
    validate :prev_phase_dates_valid?
    validate :next_phase_dates_valid?

    after_save :adjust_date_ranges
    after_save :touch_budget

    scope :enabled,           -> { where(enabled: true) }
    scope :published,         -> { enabled.where.not(kind: "drafting") }

    PHASE_KINDS.each do |phase|
      define_singleton_method(phase) { find_by_kind(phase) }
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

    private

      def adjust_date_ranges
        if enabled?
          next_enabled_phase&.update_column(:starts_at, ends_at)
          prev_enabled_phase&.update_column(:ends_at, starts_at)
        elsif enabled_changed?
          next_enabled_phase&.update_column(:starts_at, starts_at)
        end
      end

      def touch_budget
        budget.touch
      end

      def prev_phase_dates_valid?
        if enabled? && starts_at.present? && prev_enabled_phase.present?
          prev_enabled_phase.assign_attributes(ends_at: starts_at)
          if prev_enabled_phase.invalid_dates_range?
            phase_name = I18n.t("budgets.phase.#{prev_enabled_phase.kind}")
            error = I18n.t("budgets.phases.errors.prev_phase_dates_invalid", phase_name: phase_name)
            errors.add(:starts_at, error)
          end
        end
      end

      def next_phase_dates_valid?
        if enabled? && ends_at.present? && next_enabled_phase.present?
          next_enabled_phase.assign_attributes(starts_at: ends_at)
          if next_enabled_phase.invalid_dates_range?
            phase_name = I18n.t("budgets.phase.#{next_enabled_phase.kind}")
            error = I18n.t("budgets.phases.errors.next_phase_dates_invalid", phase_name: phase_name)
            errors.add(:ends_at, error)
          end
        end
      end

      def in_phase_or_later?(phase)
        PHASE_KINDS.index(kind) >= PHASE_KINDS.index(phase)
      end
  end
end
