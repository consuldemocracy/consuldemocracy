module SpendingProposalsHelper

  def spending_proposal_tags_select_options
    ActsAsTaggableOn::Tag.spending_proposal_tags.pluck(:name)
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

  def spending_proposal_count_for_geozone(geozone)
    if geozone.present?
      geozone.spending_proposals.for_summary.count
    else
      SpendingProposal.where(geozone: nil).for_summary.count
    end
  end

end