class Valuation::SpendingProposalsController < Valuation::BaseController
  include FeatureFlags
  feature_flag :spending_proposals

  has_filters %w{valuation_open valuating valuation_finished}, only: :index

  load_resource

  def index
    @spending_proposals = SpendingProposal.search(params, @current_filter).order(created_at: :desc).page(params[:page])
  end
end
