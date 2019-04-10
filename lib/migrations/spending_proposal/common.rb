module Migrations::SpendingProposal::Common
  include Migrations::SpendingProposal::Configuration
  include Migrations::Log

  def find_budget_investment(spending_proposal)
    Budget::Investment.where(original_spending_proposal_id: spending_proposal.id).first
  end

end
