class Poll
  class OfficerAssignment < ApplicationRecord
    belongs_to :officer
    belongs_to :booth_assignment
    has_many :ballot_sheets
    has_many :partial_results
    has_many :recounts
    has_many :voters

    validates :officer_id, presence: true
    validates :booth_assignment_id, presence: true
    validates :date, presence: true

    delegate :poll_id, :booth_id, to: :booth_assignment

    scope :voting_days, -> { where(final: false) }
    scope :final,       -> { where(final: true) }
    scope :by_officer_and_poll, ->(officer_id, poll_id) do
      where("officer_id = ? AND poll_booth_assignments.poll_id = ?", officer_id, poll_id)
    end
    scope :by_officer, ->(officer) { where(officer_id: officer.id) }
    scope :by_poll,  ->(poll) { joins(:booth_assignment).where("poll_booth_assignments.poll_id" => poll.id) }
    scope :by_booth, ->(booth) { joins(:booth_assignment).where("poll_booth_assignments.booth_id" => booth.id) }
    scope :by_date, ->(date) { where(date: date) }

    before_create :log_user_data

    def log_user_data
      self.user_data_log = "#{officer.user_id} - #{officer.user.name_and_email}"
    end

    def booth
      booth_assignment.booth
    end
  end
end
