class Tracking::ProposalMilestonesController < Tracking::MilestonesController

  private

    def milestoneable
      Proposal.find(params[:proposal_id])
    end
end
