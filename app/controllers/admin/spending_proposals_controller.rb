class Admin::SpendingProposalsController < Admin::BaseController
  has_filters %w{unresolved accepted rejected}, only: :index

  before_action :load_spending_proposal, except: [:index]

  def index
    @spending_proposals = SpendingProposal.send(@current_filter).order(created_at: :desc).page(params[:page])
  end

  def accept
    @spending_proposal.accept
    redirect_to request.query_parameters.merge(action: :index)
  end

  def reject
    @spending_proposal.reject
    redirect_to request.query_parameters.merge(action: :index)
  end

  private

    def load_spending_proposal
      @spending_proposal = SpendingProposal.find(params[:id])
    end

end