class Poll
  class Recount < ActiveRecord::Base
    belongs_to :booth_assignment, class_name: "Poll::BoothAssignment"
    belongs_to :officer_assignment, class_name: "Poll::OfficerAssignment"

    validates :officer_assignment_id, presence: true, uniqueness: {scope: :booth_assignment_id}
    validates :count, presence: true

    before_save :update_count_log

    def update_count_log
      self.count_log += ":#{self.count_was.to_s}" if self.count_changed? && self.count_was.present?
    end
  end
end