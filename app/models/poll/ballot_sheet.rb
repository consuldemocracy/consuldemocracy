class Poll::BallotSheet < ActiveRecord::Base
  belongs_to :poll
  belongs_to :officer_assignment

  validates :data, presence: true
  validates :poll_id, presence: true
  validates :officer_assignment_id, presence: true

  def author
    officer_assignment.officer.name
  end
end
