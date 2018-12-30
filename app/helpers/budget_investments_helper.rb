module BudgetInvestmentsHelper
  def budget_investments_advanced_filters(params)
    params.map { |af| t("admin.budget_investments.index.filters.#{af}") }.join(', ')
  end

  def link_to_investments_sorted_by(column)
    sorting_option = column.downcase
    link_to(
      t("admin.budget_investments.index.sort_by.#{sorting_option}"),
      admin_budget_budget_investments_path(sort_by: sorting_option)
    )
  end

  def investments_minimal_view_path
    custom_budget_investments_path(id: @heading.group.to_param,
                                   heading_id: @heading.to_param,
                                   filter: @current_filter,
                                   view: investments_secondary_view)
  end

  def investments_default_view?
    @view == "default"
  end

  def investments_current_view
    @view
  end

  def investments_secondary_view
    investments_current_view == "default" ? "minimal" : "default"
  end
end
