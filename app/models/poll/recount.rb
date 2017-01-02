class Poll
  class Recount < ActiveRecord::Base
    belongs_to :booth_assignment, class_name: "Poll::BoothAssignment"
    belongs_to :officer_assignment, class_name: "Poll::OfficerAssignment"

    validates :officer_assignment_id, presence: true, uniqueness: {scope: :booth_assignment_id}
    validates :count, presence: true
  end
end