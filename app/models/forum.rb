class Forum < ActiveRecord::Base
  belongs_to :user
  has_many :represented_users, class_name: User, foreign_key: :representative_id

  def has_voted?
    user.votes.for_spending_proposals(SpendingProposal.all).any?
  end

  def has_balloted?
    ballot.spending_proposals.any?
  end

  def votes_for(geozone_scope)
    user.votes.for_spending_proposals(SpendingProposal.send("#{geozone_scope}_wide"))
  end

  def ballot
    Ballot.where(user: user).first_or_create
  end

  def balloted_city_proposals
    ballot.spending_proposals.city_wide
  end

  def balloted_district_proposals
    ballot.spending_proposals.district_wide
  end

end
