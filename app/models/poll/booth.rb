class Poll
  class Booth < ActiveRecord::Base
    has_many :booth_assignments, class_name: "Poll::BoothAssignment"
    has_many :polls, through: :booth_assignments
    has_many :shifts

    validates :name, presence: true, uniqueness: true

    def self.search(terms)
      return Booth.none if terms.blank?
      Booth.where("name ILIKE ? OR location ILIKE ?", "%#{terms}%", "%#{terms}%")
    end

    def self.available
      where(polls: { id: Poll.current_or_recounting_or_incoming }).includes(:polls)
    end

    def assignment_on_poll(poll)
      booth_assignments.where(poll: poll).first
    end
  end
end
