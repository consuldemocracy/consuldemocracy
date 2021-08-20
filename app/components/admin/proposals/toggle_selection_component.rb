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
      admin_polymorphic_path(proposal, action: :toggle_selection)
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
