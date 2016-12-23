class Poll
  class Booth < ActiveRecord::Base
    has_many :booth_assignments, class_name: "Poll::BoothAssignment"
    has_many :polls, through: :booth_assignments

    validates :name, presence: true, uniqueness: true

    def self.search(terms)
      return Booth.none if terms.blank?
      Booth.where("name ILIKE ? OR location ILIKE ?", "%#{terms}%", "%#{terms}%")
    end
  end
end