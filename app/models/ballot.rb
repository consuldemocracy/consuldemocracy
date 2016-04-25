class Ballot < ActiveRecord::Base
  belongs_to :user
  has_many :ballot_lines
  has_many :spending_proposals, through: :ballot_lines

  def amount_spent
    spending_proposals.sum(:price).to_i
  end
end