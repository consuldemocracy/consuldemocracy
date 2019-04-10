class Ballot < ActiveRecord::Base
  belongs_to :user
  has_many :ballot_lines
  has_many :spending_proposals, through: :ballot_lines
end
