class Ballot < ActiveRecord::Base
  belongs_to :user
  belongs_to :geozone

  has_many :ballot_lines
  has_many :spending_proposals, through: :ballot_lines

  def add(spending_proposal)
    if valid_spending_proposal?(spending_proposal)
      ballot_lines.create(spending_proposal: spending_proposal)
      set_geozone(spending_proposal.geozone_id)
    end
  end

  def remove(spending_proposal)
    ballot_line = ballot_lines.where(spending_proposal: spending_proposal).first
    ballot_line.destroy
    reset_geozone if spending_proposal.geozone_id.present?
  end

  def amount_spent(geozone)
    spending_proposals.by_geozone(geozone).sum(:price).to_i
  end

  def amount_available(geozone)
    24000000 - amount_spent(geozone)
  end

  def total_amount_spent
    spending_proposals.sum(:price).to_i
  end

  def valid_spending_proposal?(spending_proposal)
    return false unless spending_proposal.feasibility == 'feasible'
    return false if geozone_id.present? && spending_proposal.geozone_id != geozone_id
    return false if amount_available(geozone) < spending_proposal.price.to_i
    true
  end

  def set_geozone(new_geozone_id)
    return if new_geozone_id.blank?
    self.update(geozone_id: new_geozone_id) unless new_geozone_id == geozone_id
  end

  def reset_geozone
    self.update(geozone_id: nil) if spending_proposals.district_wide.count == 0
  end

end
