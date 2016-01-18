class Admin::SpendingProposalsController < Admin::BaseController
  include FeatureFlags

  has_filters %w{unresolved accepted rejected}, only: :index

  load_and_authorize_resource

  feature_flag :spending_proposals

  def index
    @spending_proposals = @spending_proposals.includes([:geozone]).send(@current_filter).order(created_at: :desc).page(params[:page])
  end

  def show
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
