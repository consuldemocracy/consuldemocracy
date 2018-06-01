class Forum < ApplicationRecord
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

  def self.delegated_ballots
    result = {}
    all.each do |forum|
      forum.ballot.spending_proposals.each do |sp|
        result[sp.id] ||= 0
        # The votes of the original forum user have to be removed from the total
        # count of users. We use a rails counter for that (spending_proposal.ballot_lines_counter)
        # removing that vote there is complicated. It is much simpler to do so here:
        # we just remove 1 vote to compensate that when calculating the delegated votes
        result[sp.id] += (forum.represented_users.count - 1)
      end
    end
    result
  end

end
