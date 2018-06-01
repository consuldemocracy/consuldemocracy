class Poll
  class Shift < ActiveRecord::Base
    belongs_to :booth
    belongs_to :officer

    validates :booth_id, presence: true
    validates :officer_id, presence: true
    validates :date, presence: true, uniqueness: { scope: [:officer_id, :booth_id, :task] }
    validates :task, presence: true

    enum task: { vote_collection: 0, recount_scrutiny: 1 }

    scope :vote_collection,  -> { where(task: 'vote_collection') }
    scope :recount_scrutiny, -> { where(task: 'recount_scrutiny') }
    scope :current, -> { where(date: Date.current) }

    before_create :persist_data
    after_create :create_officer_assignments
    before_destroy :destroy_officer_assignments

    def persist_data
      self.officer_name = officer.name
      self.officer_email = officer.email
    end

    def create_officer_assignments
      booth.booth_assignments.each do |booth_assignment|
        attrs = {
          officer_id:          officer_id,
          date:                date,
          booth_assignment_id: booth_assignment.id,
          final:               recount_scrutiny?
        }
        Poll::OfficerAssignment.create!(attrs)
      end
    end

    def destroy_officer_assignments
      Poll::OfficerAssignment.where(booth_assignment: booth.booth_assignments,
                                    officer: officer,
                                    date: date,
                                    final: recount_scrutiny?).destroy_all
    end
  end
end
