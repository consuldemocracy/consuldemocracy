require_dependency Rails.root.join("app", "helpers", "proposals_helper").to_s

module ProposalsHelper
  def all_proposal_map_locations
    MapLocation.where(proposal_id: all_active_proposals).map(&:json_data)
  end
end
