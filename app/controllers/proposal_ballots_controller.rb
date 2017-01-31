class ProposalBallotsController < ApplicationController
  include FeatureFlags
  skip_authorization_check

  feature_flag :proposals

  def index
    @proposal_ballots = Proposal.successfull.sort_by_confidence_score
  end

end
