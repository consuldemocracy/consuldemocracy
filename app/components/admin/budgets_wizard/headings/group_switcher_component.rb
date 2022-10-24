class Admin::BudgetsWizard::Headings::GroupSwitcherComponent < ApplicationComponent
  attr_reader :group

  def initialize(group)
    @group = group
  end

  def render?
    other_groups.any?
  end

  private

    def budget
      group.budget
    end

    def other_groups
      @other_groups ||= budget.groups.sort_by_name - [group]
    end

    def headings_path(group)
      admin_budgets_wizard_budget_group_headings_path(budget, group)
    end

    def currently_showing_text
      sanitize(t("admin.budget_headings.group_switcher.currently_showing", group: group.name))
    end
end
