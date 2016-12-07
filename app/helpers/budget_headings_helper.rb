module BudgetHeadingsHelper

  def budget_heading_select_options(budget)
    budget.headings.order_by_group_name.map do |heading|
      [heading.name_scoped_by_group, heading.id]
    end
  end

end
