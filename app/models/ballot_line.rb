class BallotLine < ActiveRecord::Base
  belongs_to :ballot, counter_cache: true
  belongs_to :spending_proposal, counter_cache: true

  validate :insufficient_funds
  validate :different_geozone, :if => :district_proposal?
  validate :unfeasible
  validates :spending_proposal_id, uniqueness: { scope: :ballot_id }

  def insufficient_funds
    errors.add(:money, "") if ballot.amount_available(spending_proposal.geozone) < spending_proposal.price.to_i
  end

  def different_geozone
    errors.add(:geozone, "") if (ballot.geozone.present? && spending_proposal.geozone != ballot.geozone)
  end

  def unfeasible
    errors.add(:unfeasible, "") unless spending_proposal.feasibility == 'feasible'
  end

  def district_proposal?
    spending_proposal.geozone_id.present?
  end
end
