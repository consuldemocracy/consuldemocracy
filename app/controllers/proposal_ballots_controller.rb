class ProposalBallotsController < ApplicationController
  skip_authorization_check

  def index
    @proposal_ballots = Proposal.successfull.sort_by_confidence_score
  end

end