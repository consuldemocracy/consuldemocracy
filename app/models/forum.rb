class Forum < ActiveRecord::Base
  belongs_to :user
  has_many :represented_users, class_name: User, foreign_key: :representative_id

  def votes_for(geozone_scope)
    user.votes.for_spending_proposals(SpendingProposal.send("#{geozone_scope}_wide"))
  end

  def has_voted?
    user.votes.for_spending_proposals(SpendingProposal.all).any?
  end
end
