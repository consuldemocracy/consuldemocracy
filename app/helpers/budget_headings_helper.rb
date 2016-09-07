module BudgetHeadingsHelper

  def budget_heading_select_options(budget)
    budget.headings.map {|heading| [heading.name, heading.id]}
  end

  def budget_scoped_heading_select_options(budget)
    budget.headings.includes(:group).order("group_id ASC, budget_headings.name ASC").map {|heading| [heading.group.name + ':  ' + heading.name, heading.id]}
  end

end