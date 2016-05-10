class Ballot < ActiveRecord::Base
  belongs_to :user
  belongs_to :geozone

  has_many :ballot_lines
  has_many :spending_proposals, through: :ballot_lines

  def amount_spent(geozone)
    spending_proposals.by_geozone(geozone).sum(:price).to_i
  end

  def amount_available(geozone)
    24000000 - amount_spent(geozone)
  end

  def total_amount_spent
    spending_proposals.sum(:price).to_i
  end

  def set_geozone(new_geozone)
    return if new_geozone.blank?
    self.update(geozone: new_geozone) unless new_geozone == geozone
  end

  def reset_geozone
    self.update(geozone: nil) if spending_proposals.district_wide.count == 0
  end

end
