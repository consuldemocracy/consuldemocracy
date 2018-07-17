module CommunitiesHelper
  def community_back_link_path(community)
    if community.from_proposal?
      proposal_path(community.proposal)
    else
      budget_investment_path(community.investment.budget_id, community.investment)
    end
  end

  def create_topic_link(community)
    current_user.present? ? new_community_topic_path(community.id) : new_user_session_path
  end
end
