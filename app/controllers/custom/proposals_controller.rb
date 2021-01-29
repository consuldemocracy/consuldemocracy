require_dependency Rails.root.join("app", "controllers", "proposals_controller").to_s

class ProposalsController

  before_action :authenticate_user!, except: [:index, :show, :map, :summary, :json_data]

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

  def index_customization
    discard_draft
    discard_archived
    load_retired
    load_selected
    load_featured
    remove_archived_from_order_links
    @proposals_coordinates = all_proposal_map_locations
  end

end