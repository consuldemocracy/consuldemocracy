class Tracking::ProposalProgressBarsController <  Tracking::ProgressBarsController

  private
    def progressable
      Proposal.find(params[:proposal_id])
    end
end
