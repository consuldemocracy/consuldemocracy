module Dashboard::HasProposal
  extend ActiveSupport::Concern

  def proposal
    @proposal ||= Proposal.includes(:community).find(params[:proposal_id])
  end
end
