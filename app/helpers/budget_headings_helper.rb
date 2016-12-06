module BudgetHeadingsHelper

  def budget_heading_select_options(budget)
    budget.headings.includes(:group).order('budget_groups.name', 'budget_headings.name').map do |heading|
      ["#{heading.group.name}: #{heading.name}", heading.id]
    end
  end

end
