class Ballot < ActiveRecord::Base
  belongs_to :user
  belongs_to :geozone
  has_many :ballot_lines
  has_many :spending_proposals, through: :ballot_lines
  has_many :city_wide_spending_proposals, -> { city_wide }, through: :ballot_lines, source: :spending_proposal
  has_many :district_wide_spending_proposals, -> { district_wide }, through: :ballot_lines, source: :spending_proposal

  def add(spending_proposal)
    if valid_spending_proposal?(spending_proposal)
      ballot_lines.create(spending_proposal: spending_proposal)
      set_geozone(spending_proposal.geozone_id)
    end
  end

  def amount_spent
    spending_proposals.sum(:price).to_i
  end

  def amount_available
    24000000 - amount_spent
  end

  def city_wide_amount_spent
    city_wide_spending_proposals.sum(:price).to_i
  end

  def city_wide_amount_available
    24000000 - city_wide_amount_spent
  end

  def district_wide_amount_spent
    district_wide_spending_proposals.sum(:price).to_i
  end

  def district_wide_amount_available
    24000000 - district_wide_amount_spent
  end

  def valid_spending_proposal?(spending_proposal)
    if spending_proposal.geozone_id.present?
      return false if geozone_id.present? && spending_proposal.geozone_id != geozone_id
      return false if district_wide_amount_available < spending_proposal.price.to_i
    else
      return false if city_wide_amount_available < spending_proposal.price.to_i
    end
    true
  end

  def set_geozone(new_geozone_id)
    return if new_geozone_id.blank?
    self.update(geozone_id: new_geozone_id) unless new_geozone_id == geozone_id
  end

end
