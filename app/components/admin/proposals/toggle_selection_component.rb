class Admin::Proposals::ToggleSelectionComponent < ApplicationComponent
  include Admin::SwitchText
  attr_reader :proposal

  def initialize(proposal)
    @proposal = proposal
  end

  private

    def checked?
      proposal.selected?
    end

    def path
      admin_polymorphic_path(proposal, action: :toggle_selection)
    end

    def options
      {
        remote: true,
        method: :patch,
        class: "proposal-toggle-selection",
        "aria-label": label,
        "aria-pressed": checked?
      }
    end

    def label
      t("admin.proposals.index.select", proposal: proposal.title)
    end
end
