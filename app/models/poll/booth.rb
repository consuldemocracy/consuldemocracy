class Poll
  class Booth < ApplicationRecord
    has_many :booth_assignments
    has_many :polls, through: :booth_assignments
    has_many :shifts

    validates :name, presence: true, uniqueness: true

    def self.search(terms)
      Booth.where("name ILIKE ? OR location ILIKE ?", "%#{terms}%", "%#{terms}%")
    end

    def self.quick_search(terms)
      if terms.blank?
        Booth.none
      else
        search(terms)
      end
    end

    def self.available
      where(polls: { id: Poll.current_or_recounting }).joins(:polls)
    end

    def assignment_on_poll(poll)
      booth_assignments.find_by(poll: poll)
    end
  end
end
