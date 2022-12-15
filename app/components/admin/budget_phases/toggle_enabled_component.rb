class Admin::BudgetPhases::ToggleEnabledComponent < ApplicationComponent
  attr_reader :phase
  delegate :enabled?, to: :phase

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
        "aria-pressed": enabled?,
        form_class: "toggle-switch"
      }
    end

    def action
      if enabled?
        :disable
      else
        :enable
      end
    end

    def text
      if enabled?
        t("shared.yes")
      else
        t("shared.no")
      end
    end
end
