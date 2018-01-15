class Budget
  class Phase < ActiveRecord::Base
    PHASE_KINDS = %w(drafting accepting reviewing selecting valuating publishing_prices balloting
                reviewing_ballots finished).freeze
    PUBLISHED_PRICES_PHASES = %w(publishing_prices balloting reviewing_ballots finished).freeze
    DESCRIPTION_MAX_LENGTH = 2000

    belongs_to :budget
    belongs_to :next_phase, class_name: 'Budget::Phase', foreign_key: :next_phase_id
    has_one :prev_phase, class_name: 'Budget::Phase', foreign_key: :next_phase_id

    validates :budget, presence: true
    validates :kind, presence: true, uniqueness: { scope: :budget }, inclusion: { in: PHASE_KINDS }
    validates :description, length: { maximum: DESCRIPTION_MAX_LENGTH }
    validate :dates_range_valid?

    before_validation :sanitize_description


    scope :enabled,           -> { where(enabled: true) }
    scope :drafting,          -> { find_by_kind('drafting') }
    scope :accepting,         -> { find_by_kind('accepting')}
    scope :reviewing,         -> { find_by_kind('reviewing')}
    scope :selecting,         -> { find_by_kind('selecting')}
    scope :valuating,         -> { find_by_kind('valuating')}
    scope :publishing_prices, -> { find_by_kind('publishing_prices')}
    scope :balloting,         -> { find_by_kind('balloting')}
    scope :reviewing_ballots, -> { find_by_kind('reviewing_ballots')}
    scope :finished,          -> { find_by_kind('finished')}

    def next_enabled_phase
      next_phase&.enabled? ? next_phase : next_phase&.next_enabled_phase
    end

    def prev_enabled_phase
      prev_phase&.enabled? ? prev_phase : prev_phase&.prev_enabled_phase
    end

    def dates_range_valid?
      if starts_at.present? && ends_at.present? && starts_at >= ends_at
        errors.add(:starts_at, I18n.t('budgets.phases.errors.dates_range_invalid'))
      end
    end


    def sanitize_description
      self.description = WYSIWYGSanitizer.new.sanitize(description)
    end
  end
end
