class HumanRightsController < ApplicationController
  skip_authorization_check
  include CommentableActions

  def index
    load_human_right_proposals
    filter_by_subproceeding

    load_votes
    load_tags
    load_subproceedings

    paginate_results
    render "proposals/index"
  end

  private

  def load_human_right_proposals
    @proposals = @human_right_proposals = Proposal.where(proceeding: "Derechos Humanos")
  end

  def filter_by_subproceeding
    @proposals = @proposals.where("sub_proceeding = ?", params[:sub_proceeding]) if params[:sub_proceeding].present?
  end

  def load_votes
    set_resource_votes(@proposals)
  end

  def load_tags
    @tag_cloud = tag_cloud
  end

  def load_subproceedings
    @subproceedings = @human_right_proposals.distinct.pluck(:sub_proceeding)
  end

  def paginate_results
    @proposals = @proposals.page(params[:page])
  end

  def resource_name
    "proposal"
  end

  def resource_model
    Proposal
  end

end