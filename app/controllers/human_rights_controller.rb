class HumanRightsController < ApplicationController
  skip_authorization_check
  include CommentableActions

  def index
    @proposals = Proposal.where(proceeding: "Derechos Humanos").page(params[:page])
    set_resource_votes(@proposals)
    @tag_cloud = tag_cloud
    @categories = @proposals.distinct.pluck(:sub_proceeding)
    render "proposals/index"
  end

  private

  def resource_name
    "proposal"
  end

  def resource_model
    Proposal
  end

end