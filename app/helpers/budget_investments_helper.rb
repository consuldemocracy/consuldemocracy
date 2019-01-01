module BudgetInvestmentsHelper
  def budget_investments_advanced_filters(params)
    params.map { |af| t("admin.budget_investments.index.filters.#{af}") }.join(', ')
  end

  def link_to_investments_sorted_by(column)
    sort_by = column.downcase
    allowed_directions = %w[asc desc].freeze
    default_direction = "desc"
    current_direction = params[:direction]

    if allowed_directions.include?(current_direction)
      #select opposite direction
      direction = allowed_directions.reject { |dir| dir == current_direction }.first
    else
      direction = default_direction
    end

    icon = direction == default_direction ? "icon-arrow-top" : "icon-arrow-down"
    icon = sort_by == params[:sort_by] ? icon : ""

    translation = t("admin.budget_investments.index.sort_by.#{sort_by}")

    link_to(
      "#{translation} <span class=\"#{icon}\"></span>".html_safe,
      admin_budget_budget_investments_path(sort_by: sort_by, direction: direction)
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
