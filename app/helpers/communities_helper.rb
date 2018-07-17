module CommunitiesHelper
  def community_back_link_path(community)
    if community.communitable_type == "Proposal"
      proposal_path(community.communitable)
    else
      budget_investment_path(community.communitable.budget_id, community.communitable)
    end
  end

  def create_topic_link(community)
    current_user.present? ? new_community_topic_path(community.id) : new_user_session_path
  end
end
