class Admin::ProposalsController < Admin::BaseController
  include HasOrders
  include CommentableActions
  include FeatureFlags
  feature_flag :proposals

  has_orders %w[created_at]

  def show
    @proposal = Proposal.find(params[:id])
  end

  private

    def resource_model
      Proposal
    end
end
