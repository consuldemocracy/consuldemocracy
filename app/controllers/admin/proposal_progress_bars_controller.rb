class Admin::ProposalProgressBarsController < Admin::ProgressBarsController
  private

    def progressable
      Proposal.find(params[:proposal_id])
    end
end
