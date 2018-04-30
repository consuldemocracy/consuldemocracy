class ValuationAssignment < ActiveRecord::Base
  belongs_to :valuator, counter_cache: :spending_proposals_count
  belongs_to :spending_proposal, counter_cache: true
end

# == Schema Information
#
# Table name: valuation_assignments
#
#  id                   :integer          not null, primary key
#  valuator_id          :integer
#  spending_proposal_id :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
