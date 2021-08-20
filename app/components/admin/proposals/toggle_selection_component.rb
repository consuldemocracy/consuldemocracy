class Admin::Proposals::ToggleSelectionComponent < ApplicationComponent
  attr_reader :proposal

  def initialize(proposal)
    @proposal = proposal
  end

  private

    def text
      if proposal.selected?
        t("admin.proposals.index.selected")
      else
        t("admin.proposals.index.select")
      end
    end

    def path
      case proposal.class.to_s
      when "Proposal"
        toggle_selection_admin_proposal_path(proposal)
      when "Legislation::Proposal"
        toggle_selection_admin_legislation_process_proposal_path(proposal.process, proposal)
      end
    end

    def options
      { remote: true, method: :patch, class: html_class }
    end

    def html_class
      if proposal.selected?
        "button expanded"
      else
        "button hollow expanded"
      end
    end
end
