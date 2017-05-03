class Poll
  class FinalRecount < ActiveRecord::Base
    belongs_to :booth_assignment, class_name: "Poll::BoothAssignment"
    belongs_to :officer_assignment, class_name: "Poll::OfficerAssignment"

    validates :booth_assignment_id, presence: true
    validates :date, presence: true, uniqueness: {scope: :booth_assignment_id}
    validates :count, presence: true, numericality: {only_integer: true}

    before_save :update_logs

    def update_logs
      if self.count_changed? && self.count_was.present?
        self.count_log += ":#{self.count_was.to_s}"
        self.officer_assignment_id_log += ":#{self.officer_assignment_id_was.to_s}"
      end
    end
  end
end