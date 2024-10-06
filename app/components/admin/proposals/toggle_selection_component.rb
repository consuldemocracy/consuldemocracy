class Admin::Proposals::ToggleSelectionComponent < ApplicationComponent
  attr_reader :proposal

  def initialize(proposal)
    @proposal = proposal
  end

  private

    def action
      if selected?
        :deselect
      else
        :select
      end
    end

    def selected?
      proposal.selected?
    end

    def options
      {
        "aria-label": label
      }
    end

    def label
      t("admin.actions.label", action: t("admin.actions.select"), name: proposal.title)
    end
end
