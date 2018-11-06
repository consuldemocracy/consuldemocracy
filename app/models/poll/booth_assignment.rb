class Poll
  class BoothAssignment < ActiveRecord::Base
    belongs_to :booth
    belongs_to :poll

    before_destroy :destroy_poll_shifts, only: :destroy

    has_many :officer_assignments, class_name: "Poll::OfficerAssignment", dependent: :destroy
    has_many :officers, through: :officer_assignments
    has_many :voters
    has_many :partial_results
    has_many :recounts

    def shifts?
      shifts.empty? ? false : true
    end

    private

      def shifts
        Poll::Shift.where(booth_id: booth_id, officer_id: officer_assignments.pluck(:officer_id), date: officer_assignments.pluck(:date))
      end

      def destroy_poll_shifts
        shifts.destroy_all
      end
  end
end
