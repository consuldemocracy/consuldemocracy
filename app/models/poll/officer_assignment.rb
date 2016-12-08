class Poll
  class OfficerAssignment < ActiveRecord::Base
    belongs_to :officer
    belongs_to :booth_assignment

    delegate :poll_id, :booth_id, to: :booth_assignment
  end
end
