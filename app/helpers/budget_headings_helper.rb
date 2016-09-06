module BudgetHeadingsHelper

  def budget_heading_select_options(budget)
    budget.headings.map {|heading| [heading.name, heading.id]}
  end

end