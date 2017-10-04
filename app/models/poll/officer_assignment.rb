class Poll
  class OfficerAssignment < ActiveRecord::Base
    belongs_to :officer
    belongs_to :booth_assignment
    has_many :partial_results
    has_many :recounts
    has_many :voters

    validates :officer_id, presence: true
    validates :booth_assignment_id, presence: true
    validates :date, presence: true

    delegate :poll_id, :booth_id, to: :booth_assignment

    scope :voting_days, -> { where(final: false) }
    scope :final,       -> { where(final: true) }

    before_create :log_user_data

    def log_user_data
      self.user_data_log = "#{officer.user_id} - #{officer.user.name_and_email}"
    end
  end
end
