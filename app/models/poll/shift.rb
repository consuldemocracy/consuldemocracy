class Poll
  class Shift < ActiveRecord::Base
  	belongs_to :booth
  	belongs_to :officer

    validates :booth_id, presence: true
    validates :officer_id, presence: true
    validates :date, presence: true
    validates :date, uniqueness: { scope: [:officer_id, :booth_id] }
    
    before_create :persist_data
    after_create :create_officer_assignments

    def create_officer_assignments
      booth.booth_assignments.each do |booth_assignment|
        attrs = { officer_id:          officer_id,
                  date:                date,
                  booth_assignment_id: booth_assignment.id }
        Poll::OfficerAssignment.create!(attrs)
      end
    end

    def persist_data      
      self.officer_name = officer.name
      self.officer_email = officer.email
    end

  end
 end