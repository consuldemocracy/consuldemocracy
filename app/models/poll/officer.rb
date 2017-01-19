class Poll
  class Officer < ActiveRecord::Base
    belongs_to :user
    has_many :officer_assignments, class_name: "Poll::OfficerAssignment"

    validates :user_id, presence: true, uniqueness: true

    delegate :name, :email, to: :user

    def assigned_polls
      officer_assignments.includes(booth_assignment: :poll).
                               map(&:booth_assignment).
                               map(&:poll).uniq.compact.
                               sort {|x, y| y.ends_at <=> x.ends_at}
    end

  end
end