class Admin::BudgetsWizard::Headings::EditComponent < ApplicationComponent
  include Header
  attr_reader :heading

  def initialize(heading)
    @heading = heading
  end

  def budget
    heading.budget
  end

  def group
    heading.group
  end

  def title
    heading.name
  end

  private

    def form_path
      admin_budgets_wizard_budget_group_heading_path(budget, group, heading)
    end
end
