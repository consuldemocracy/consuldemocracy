class ValuationAssignment < ActiveRecord::Base
  belongs_to :valuator, counter_cache: :spending_proposals_count
  belongs_to :spending_proposal, counter_cache: true
end
