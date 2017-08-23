module SpendingProposalsHelper

  def spending_proposal_tags_select_options
    ActsAsTaggableOn::Tag.spending_proposal_tags.pluck(:name)
  end

  def namespaced_spending_proposal_path(spending_proposal, options = {})
    @namespace_spending_proposal_path ||= namespace
    case @namespace_spending_proposal_path
    when "management"
      management_spending_proposal_path(spending_proposal, options)
    else
      spending_proposal_path(spending_proposal, options)
    end
  end

  def spending_proposal_count_for_geozone(scope, geozone, second_scope)
    if geozone.present?
      geozone.spending_proposals.send(scope).send(second_scope).count
    else
      SpendingProposal.where(geozone: nil).send(scope).send(second_scope).count
    end
  end

end