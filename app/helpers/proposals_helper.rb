module ProposalsHelper

  def progress_bar_percentage(proposal)
    case proposal.cached_votes_up
    when 0 then 0
    when 1..Proposal.votes_needed_for_success then (proposal.total_votes.to_f * 100 / Proposal.votes_needed_for_success).floor
    else 100
    end
  end

  def supports_percentage(proposal)
    percentage = (proposal.total_votes.to_f * 100 / Proposal.votes_needed_for_success)
    case percentage
    when 0 then "0%"
    when 0..0.1 then "0.1%"
    when 0.1..100 then number_to_percentage(percentage, strip_insignificant_zeros: true, precision: 1)
    else "100%"
    end
  end

  def namespaced_proposal_path(proposal, options = {})
    return human_rights_proposal_path(proposal) if proposal.proceeding?

    @namespace_proposal_path ||= namespace
    case @namespace_proposal_path
    when "management"
      management_proposal_path(proposal, options)
    else
      proposal_path(proposal, options)
    end
  end

  def retire_proposals_options
    Proposal::RETIRE_OPTIONS.collect { |option| [ t("proposals.retire_options.#{option}"), option ] }
  end

  def empty_recommended_proposals_message_text(user)
    if user.interests.any?
      t('proposals.index.recommendations.without_results')
    else
      t('proposals.index.recommendations.without_interests')
    end
  end

  def author_of_proposal?(proposal)
    author_of?(proposal, current_user)
  end

  def current_editable?(proposal)
    current_user && proposal.editable_by?(current_user)
  end

  def link_to_new_proposal_proceeding_path(proceeding, sub_proceeding, title = nil)
    link_to title || sub_proceeding, new_proposal_path(proceeding: proceeding, sub_proceeding: sub_proceeding)
  end

  def css_for_successfull_proposal(proposal)
    "successful" if proposal.total_votes > Proposal.votes_needed_for_success
  end

  def path_to_search_proposals
    if controller_name == "human_rights"
      human_rights_proposals_path(page: 1)
    else
      proposals_path(page: 1)
    end
  end

  def can_create_document?(document, proposal)
    can?(:create, document) && proposal.documents.size < Proposal.max_documents_allowed
  end

end
