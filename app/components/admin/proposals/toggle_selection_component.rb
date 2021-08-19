class Admin::Proposals::ToggleSelectionComponent < ApplicationComponent
  attr_reader :proposal

  def initialize(proposal)
    @proposal = proposal
  end

  def link_to_toggle_proposal_selection
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
end
