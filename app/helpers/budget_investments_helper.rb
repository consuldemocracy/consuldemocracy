module BudgetInvestmentsHelper
  def budget_investments_sorting_options
    Budget::Investment::SORTING_OPTIONS.map do |so|
      [t("admin.budget_investments.index.sort_by.#{so}"), so]
    end
  end

  def budget_investments_advanced_filters(params)
    params.map { |af| t("admin.budget_investments.index.filters.#{af}") }.join(', ')
  end

  def investments_minimal_view_path
    budget_investments_path(id: @heading.group.to_param,
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
