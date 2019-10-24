module BudgetHeadingsHelper
  def budget_heading_select_options(budget)
    budget.headings.sort_by_name.map do |heading|
      [heading.name_scoped_by_group, heading.id]
    end
  end

  def heading_link(assigned_heading = nil, budget = nil)
    return nil unless assigned_heading && budget

    heading_path = budget_investments_path(budget, heading_id: assigned_heading&.id)
    link_to(assigned_heading.name, heading_path)
  end
end
