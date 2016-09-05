module BudgetGroupsHelper

  def budget_group_select_options(groups)
    groups.map {|group| [group.name, group.id]}
  end

end