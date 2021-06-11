class Admin::BudgetsWizard::Groups::IndexComponent < Admin::BudgetsWizard::BaseComponent
  include Header
  attr_reader :groups, :new_group

  def initialize(groups, new_group)
    @groups = groups
    @new_group = new_group
  end

  def budget
    @new_group.budget
  end

  def title
    budget.name
  end
end
