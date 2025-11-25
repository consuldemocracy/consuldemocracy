class Event < ApplicationRecord
  # 1. Capabilities
  include CalendarItem
  include Imageable

  # 2. Validations
  validates :name, :starts_at, presence: true
  validates :ends_at, presence: true

  validates :starts_at,
            comparison: {
              less_than_or_equal_to: :ends_at,
              message: ->(*) { I18n.t("errors.messages.invalid_date_range") }
            },
            allow_blank: true,
            if: -> { ends_at }


  def self.all_in_range(start_date, end_date)
    # FIX: Use full day range to capture events happening late in the day
    range = start_date.beginning_of_day..end_date.end_of_day

    # A. Manual Events
    events = self.where(starts_at: range)

    # B. Budgets
    budgets = Budget.published.includes(:phases).select do |b|
      b.calendar_start.present? && range.cover?(b.calendar_start)
    end

    # C. Budget Phases
    budget_phases = Budget::Phase.joins(:budget)
                                 .merge(Budget.published)
                                 .where(enabled: true)
                                 .where(starts_at: range)

    # D. Legislation
    processes = Legislation::Process.open.where(start_date: range)

    # E. Polls
    polls = defined?(Poll) ? Poll.where(starts_at: range) : []

    (events + budgets + budget_phases + processes + polls).sort_by(&:calendar_start)
  end

  # 4. Interface
  def kind
    "generic_event"
  end

  # We define this clearly so the Calendar knows exactly what to use
  def calendar_start
    starts_at
  end
end
