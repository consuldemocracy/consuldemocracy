class Admin::BudgetPhases::PhasesComponent < ApplicationComponent
  attr_reader :budget, :form

  def initialize(budget, form: nil)
    @budget = budget
    @form = form
  end

  private

    def phases
      budget.phases.order(:id)
    end

    def dates(phase)
      Admin::Budgets::DurationComponent.new(phase).dates
    end

    def enabled_cell(phase)
      if form
        form.fields_for :phases, phase do |phase_fields|
          phase_fields.check_box :enabled,
                                 label: false,
                                 aria: {
                                   label: t("admin.budgets.edit.enable_phase", phase: phase.name)
                                 }
        end
      else
        enabled_text(phase)
      end
    end

    def enabled_text(phase)
      if phase.enabled?
        tag.span t("shared.yes"), class: "budget-phase-enabled"
      else
        tag.span t("shared.no"), class: "budget-phase-disabled"
      end
    end

    def edit_path(phase)
      if helpers.respond_to?(:single_heading?) && helpers.single_heading?
        edit_admin_budgets_wizard_budget_budget_phase_path(budget, phase, helpers.url_params)
      end
    end
end
