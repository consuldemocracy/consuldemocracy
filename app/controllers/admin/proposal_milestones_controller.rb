class Admin::ProposalMilestonesController < Admin::MilestonesController

  private

  def milestoneable
    Proposal.find(params[:proposal_id])
  end
end
