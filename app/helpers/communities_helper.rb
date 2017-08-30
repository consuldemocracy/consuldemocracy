module CommunitiesHelper

  def community_title(community)
    if community.from_proposal?
      community.proposal.title
    else
      investment = Budget::Investment.where(community_id: community.id).first
      investment.title
    end
  end

  def community_text(community)
    community.from_proposal? ? t("community.show.title.proposal") : t("community.show.title.investment")
  end

  def community_description(community)
    community.from_proposal? ? t("community.show.description.proposal") : t("community.show.description.investment")
  end

  def is_author?(community, participant)
    if community.from_proposal?
      community.proposal.author_id == participant.id
    else
      investment = Budget::Investment.where(community_id: community.id).first
      investment.author_id == participant.id
    end
  end

end
