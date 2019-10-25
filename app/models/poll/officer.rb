class Poll
  class Officer < ApplicationRecord
    belongs_to :user
    has_many :officer_assignments
    has_many :shifts
    has_many :failed_census_calls, foreign_key: :poll_officer_id, inverse_of: :poll_officer

    validates :user_id, presence: true, uniqueness: true

    def name
      user&.name || I18n.t("shared.author_info.author_deleted")
    end

    def email
      user&.email || I18n.t("shared.author_info.email_deleted")
    end

    def voting_days_assigned_polls
      officer_assignments.voting_days.includes(booth_assignment: :poll).
                               map(&:booth_assignment).
                               map(&:poll).uniq.compact.
                               sort { |x, y| y.ends_at <=> x.ends_at }
    end

    def final_days_assigned_polls
      officer_assignments.final.includes(booth_assignment: :poll).
                               map(&:booth_assignment).
                               map(&:poll).uniq.compact.
                               sort { |x, y| y.ends_at <=> x.ends_at }
    end

    def todays_booths
      officer_assignments.by_date(Date.current).map(&:booth).uniq
    end
  end
end
