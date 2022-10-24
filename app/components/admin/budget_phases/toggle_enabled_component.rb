class Admin::BudgetPhases::ToggleEnabledComponent < ApplicationComponent
  attr_reader :phase

  def initialize(phase)
    @phase = phase
  end

  private

    def options
      {
        text: text,
        method: :patch,
        remote: true,
        "aria-label": t("admin.budgets.edit.enable_phase", phase: phase.name),
        "aria-pressed": phase.enabled?
      }
    end

    def text
      if phase.enabled?
        t("shared.yes")
      else
        t("shared.no")
      end
    end
end
