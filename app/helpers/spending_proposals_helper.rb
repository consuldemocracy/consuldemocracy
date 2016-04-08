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

  def supports_confirm_for_current_user(spending_proposal)
    confirm = ""

    if current_user.try(:pending_delegation_alert?)
      confirm += t("votes.spending_proposals.confirm_discard_delegation")
    end

    if has_not_voted_for_district?(spending_proposal)
       confirm += t('votes.spending_proposals.confirm_first_vote_on_district',
                  district: spending_proposal.geozone.name)
    end

    confirm.blank? ? nil : {confirm: confirm }
  end

  def has_not_voted_for_district?(spending_proposal)
    current_user.present? &&
    spending_proposal.present? &&
    current_user.supported_spending_proposals_geozone_id.blank? &&
    spending_proposal.geozone_id.present?
  end

  def first_time_voting_spending_proposal_for_district?(spending_proposal)
    spending_proposal.district_wide? &&
      current_user.district_wide_spending_proposals_supported_count == 9
  end

  def last_available_vote_on_spending_proposal?(spending_proposal)
    (spending_proposal.district_wide? && current_user.district_wide_spending_proposals_supported_count == 0) ||
    (spending_proposal.city_wide? && current_user.city_wide_spending_proposals_supported_count == 0)
  end

  def has_accepted_delegation_alert?
    @accepted_delegation_alert
  end

  def namespaced_spending_proposal_path(spending_proposal, options={})
    @namespace_spending_proposal_path ||= namespace
    case @namespace_spending_proposal_path
    when "management"
      management_spending_proposal_path(spending_proposal, options)
    else
      spending_proposal_path(spending_proposal, options)
    end
  end
end
