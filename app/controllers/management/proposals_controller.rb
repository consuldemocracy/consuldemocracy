class Management::ProposalsController < Management::BaseController
  skip_before_action :verify_manager
  include HasOrders

  before_action :set_proposal, only: :vote
  has_orders %w{hot_score confidence_score created_at most_commented random}, only: :index

  def index
    @proposals = Proposal.all.limit(10).page(params[:page])
  end

  def vote
    @proposal.register_vote(current_user, 'yes')
    redirect_to management_proposals_url, notice: "Succesfully voted"
  end

  private

    def set_proposal
      @proposal = Proposal.find(params[:id])
    end

    def set_proposal_votes(proposals)
      @proposal_votes = current_user ? current_user.proposal_votes(proposals) : {}
    end

    def current_user
      #CHANGE ME
      #Should be user being managed
      User.first
    end

end