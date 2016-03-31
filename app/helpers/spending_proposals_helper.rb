module SpendingProposalsHelper

  def spending_proposal_tags_select_options
    ActsAsTaggableOn::Tag.spending_proposal_tags.pluck(:name)
  end

  def can_support_spending_proposals_on_current_district?
     @filter_geozone.blank? ||
       current_user.blank? ||
       current_user.supported_spending_proposals_geozone_id.blank? ||
       current_user.supported_spending_proposals_geozone_id == @filter_geozone.id
  end
end
