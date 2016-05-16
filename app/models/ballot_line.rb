class BallotLine < ActiveRecord::Base
  belongs_to :ballot, counter_cache: true
  belongs_to :spending_proposal
end