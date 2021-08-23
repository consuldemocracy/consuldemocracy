class Admin::BudgetPhases::PhasesComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def phases
      budget.phases.order(:id)
    end

    def dates(phase)
      Admin::Budgets::DurationComponent.new(phase).dates
    end

    def enabled_cell(phase)
      render Admin::BudgetPhases::ToggleEnabledComponent.new(phase)
    end

    def edit_path(phase)
      if helpers.respond_to?(:single_heading?) && helpers.single_heading?
        edit_admin_budgets_wizard_budget_budget_phase_path(budget, phase, helpers.url_params)
      end
    end
end
