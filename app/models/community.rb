class Community < ActiveRecord::Base
  has_one :proposal
  has_one :investment
  has_many :topics

  def participants
    User.community_participants(self)
  end

  def from_proposal?
    self.proposal.present?
  end

end
