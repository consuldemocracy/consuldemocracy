class Admin::BudgetsWizard::Headings::CreationStepComponent < ApplicationComponent
  attr_reader :heading

  def initialize(heading)
    @heading = heading
  end

  private

    def budget
      heading.budget
    end

    def form_path
      if heading.persisted?
        admin_budgets_wizard_budget_group_heading_path(heading.group.budget, heading.group, heading)
      else
        admin_budgets_wizard_budget_group_headings_path(heading.group.budget, heading.group)
      end
    end

    def next_step_path
      admin_budgets_wizard_budget_budget_phases_path(budget) if next_step_enabled?
    end

    def next_step_enabled?
      budget.headings.any?
    end
end
