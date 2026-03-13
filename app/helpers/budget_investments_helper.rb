module BudgetInvestmentsHelper
  def budget_investments_advanced_filters(params)
    params.map { |af| t("admin.budget_investments.index.filters.#{af}") }.join(", ")
  end

  def set_sorting_icon(direction, sort_by)
    if sort_by.to_s == params[:sort_by]
      if direction == "desc"
        "desc"
      else
        "asc"
      end
    else
      ""
    end
  end

  def set_direction(current_direction)
    current_direction == "desc" ? "asc" : "desc"
  end

  def show_author_actions?(investment)
    can?(:edit, investment) || can_destroy_image?(investment)
  end
end
