class Management::ProposalsController < Management::BaseController
  include HasOrders

  has_orders %w{hot_score confidence_score created_at most_commented random}, only: :index

  def index
    @proposals = Proposal.all.limit(10).page(params[:page])
    @tag_cloud = []
    set_proposal_votes(@proposals)
  end

  private

    def set_proposal_votes(proposals)
      @proposal_votes = current_user ? current_user.proposal_votes(proposals) : {}
    end

end