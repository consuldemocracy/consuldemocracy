class Ballot < ActiveRecord::Base
  belongs_to :user
  has_many :ballot_lines
  has_many :spending_proposals, through: :ballot_lines
  has_many :city_wide_spending_proposals, -> { city_wide }, through: :ballot_lines, source: :spending_proposal
  has_many :district_wide_spending_proposals, -> { district_wide }, through: :ballot_lines, source: :spending_proposal


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

end
