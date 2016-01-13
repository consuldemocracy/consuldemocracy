class Admin::SpendingProposalsController < Admin::BaseController
  has_filters %w{unresolved accepted rejected}, only: :index

  load_and_authorize_resource

  def index
    @spending_proposals = @spending_proposals.includes([:geozone]).send(@current_filter).order(created_at: :desc).page(params[:page])
  end

  def show
    @spending_proposal = @spending_proposal.includes([:author, :geozone])
  end

  def accept
    @spending_proposal.accept
    redirect_to request.query_parameters.merge(action: :index)
  end

  def reject
    @spending_proposal.reject
    redirect_to request.query_parameters.merge(action: :index)
  end

end
