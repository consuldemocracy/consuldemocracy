class Admin::BudgetPhases::ToggleEnabledComponent < ApplicationComponent
  attr_reader :phase
  delegate :enabled?, to: :phase

  def initialize(phase)
    @phase = phase
  end

  private

    def options
      { "aria-label": t("admin.budgets.edit.enable_phase", phase: phase.name) }
    end

    def action
      if enabled?
        :disable
      else
        :enable
      end
    end
end
