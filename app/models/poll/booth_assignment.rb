class Poll
  class BoothAssignment < ActiveRecord::Base
    belongs_to :booth
    belongs_to :poll

    has_many :officer_assignments, class_name: "Poll::OfficerAssignment", dependent: :destroy
    has_many :officers, through: :officer_assignments
    has_many :voters
    has_many :partial_results
    has_many :recounts

    before_destroy :destroy_poll_shifts
    
    def has_shifts?
      
    end

    private

      def destroy_poll_shifts
#        officers = poll.officers_in_booth(booth.id)
#        Poll::Shift.where(officer_id: officers, booth_id: booth.id)
      end
  end
end
