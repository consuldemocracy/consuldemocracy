class Poll
  class Booth < ActiveRecord::Base
    has_many :booth_assignments, class_name: "Poll::BoothAssignment"
    has_many :polls, through: :booth_assignments
    has_many :voters

    validates :name, presence: true, uniqueness: true
  end
end