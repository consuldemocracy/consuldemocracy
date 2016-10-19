class HumanRightsController < ApplicationController
  skip_authorization_check
  include CommentableActions

  def index
    @proposals = human_right_proposals
    @proposals = @proposals.where("sub_proceeding = ?", params[:sub_proceeding]) if params[:sub_proceeding].present?

    set_resource_votes(@proposals)

    @tag_cloud = tag_cloud
    @categories = human_right_proposals.distinct.pluck(:sub_proceeding)

    @proposals = @proposals.page(params[:page])
    render "proposals/index"
  end

  private

  def human_right_proposals
    @human_right_proposals ||= Proposal.where(proceeding: "Derechos Humanos")
  end

  def resource_name
    "proposal"
  end

  def resource_model
    Proposal
  end

end