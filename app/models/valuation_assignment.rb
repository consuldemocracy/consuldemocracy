class ValuationAssignment < ActiveRecord::Base
  belongs_to :valuator
  belongs_to :spending_proposal
end
