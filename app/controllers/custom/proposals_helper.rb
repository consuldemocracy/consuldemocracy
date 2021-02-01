require_dependency Rails.root.join("app", "helpers", "proposals_helper").to_s

module ProposalsHelper

  def all_proposal_map_locations
    ids = if params[:search]
      Proposal.search(params[:search]).pluck(:id)
    elsif params[:tags]
      Proposal.not_archived.published.tagged_with(params[:tags].split(","), all: true)
    else
      Proposal.not_archived.published.pluck(:id)
    end
      MapLocation.where(proposal_id: ids).map(&:json_data)
  end

  def json_data
    proposal = Proposal.find(params[:id])
    data = {
      proposal_id: proposal.id,
      proposal_title: proposal.title
    }.to_json

    respond_to do |format|
      format.json { render json: data }
    end
  end

end
