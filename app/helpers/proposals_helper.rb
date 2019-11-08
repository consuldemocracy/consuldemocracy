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

  def proposals_minimal_view_path
    proposals_path(view: proposals_secondary_view)
  end

  def proposals_default_view?
    @view == "default"
  end

  def proposals_current_view
    @view
  end

  def proposals_secondary_view
    proposals_current_view == "default" ? "minimal" : "default"
  end

  def link_to_toggle_proposal_selection(proposal)
    if proposal.selected?
      button_text = t("admin.proposals.index.selected")
      html_class = "button expanded"
    else
      button_text = t("admin.proposals.index.select")
      html_class = "button hollow expanded"
    end

    case proposal.class.to_s
    when "Proposal"
      path = toggle_selection_admin_proposal_path(proposal)
    when "Legislation::Proposal"
      path = toggle_selection_admin_legislation_process_proposal_path(proposal.process, proposal)
    end

    link_to button_text, path, remote: true, method: :patch, class: html_class
  end

  def css_for_proposal_info_row(proposal)
    if proposal.image.present?
      if params[:selected].present?
        "small-12 medium-9 column"
      else
        "small-12 medium-6 large-7 column"
      end
    else
      if params[:selected].present?
        "small-12 column"
      else
        "small-12 medium-9 column"
      end
    end
  end

  def show_proposal_votes?
    params[:selected].blank?
  end

  def show_featured_proposals?
    params[:selected].blank? && @featured_proposals.present?
  end

  def show_recommended_proposals?
    params[:selected].blank? && feature?("user.recommendations") && @recommended_proposals.present?
  end
end
