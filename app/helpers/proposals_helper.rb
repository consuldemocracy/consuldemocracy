module ProposalsHelper
  def namespaced_proposal_path(proposal, options = {})
    @namespace_proposal_path ||= namespace
    case @namespace_proposal_path
    when "management"
      management_proposal_path(proposal, options)
    else
      proposal_path(proposal, options)
    end
  end

  def retire_proposals_options
    Proposal::RETIRE_OPTIONS.map { |option| [t("proposals.retire_options.#{option}"), option] }
  end

  def empty_recommended_proposals_message_text(user)
    if user.interests.any?
      t("proposals.index.recommendations.without_results")
    else
      t("proposals.index.recommendations.without_interests")
    end
  end

  def author_of_proposal?(proposal)
    author_of?(proposal, current_user)
  end

  def current_editable?(proposal)
    current_user && proposal.editable_by?(current_user)
  end

  def proposals_secondary_view_path
    proposals_path(view: secondary_view_mode)
  end

  def show_proposal_votes?
    params[:selected].blank?
  end

  def show_recommended_proposals?
    params[:selected].blank?
  end
end
