class Admin::ProposalsController < Admin::BaseController
  include FeatureFlags
  feature_flag :proposals

  def index
    @proposals = Proposal.sort_by_created_at.page(params[:page])
  end

  def show
    @proposal = Proposal.find(params[:id])
  end
end
