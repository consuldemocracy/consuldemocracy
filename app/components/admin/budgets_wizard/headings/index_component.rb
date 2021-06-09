class Admin::BudgetsWizard::Headings::IndexComponent < ApplicationComponent
  include Header
  attr_reader :headings, :new_heading

  def initialize(headings, new_heading)
    @headings = headings
    @new_heading = new_heading
  end

  def budget
    group.budget
  end

  def group
    new_heading.group
  end

  def title
    t("admin.budget_headings.index.title", budget: budget.name, group: group.name)
  end
end
