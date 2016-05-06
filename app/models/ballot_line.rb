class BallotLine < ActiveRecord::Base
  belongs_to :ballot
  belongs_to :spending_proposal
end