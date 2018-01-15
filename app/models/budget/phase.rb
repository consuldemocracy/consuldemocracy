class Budget
  class Phase < ActiveRecord::Base
    DESCRIPTION_MAX_LENGTH = 2000

    belongs_to :budget
    belongs_to :next_phase, class_name: 'Budget::Phase', foreign_key: :next_phase_id
    has_one :prev_phase, class_name: 'Budget::Phase', foreign_key: :next_phase_id

    validates :budget, presence: true
    validates :kind, presence: true, uniqueness: { scope: :budget }, inclusion: { in: Budget::PHASES }
    validates :description, length: { maximum: DESCRIPTION_MAX_LENGTH }
    validate :dates_range_valid?

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

    def dates_range_valid?
      if starts_at.present? && ends_at.present? && starts_at >= ends_at
        errors.add(:starts_at, I18n.t('budgets.phases.errors.dates_range_invalid'))
      end
    end

  end
end
