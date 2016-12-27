class Poll
  class Officer < ActiveRecord::Base
    belongs_to :user
    has_many :officer_assignments, class_name: "Poll::OfficerAssignment"

    validates :user_id, presence: true, uniqueness: true

    delegate :name, :email, to: :user
  end
end