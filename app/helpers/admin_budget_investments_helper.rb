module AdminBudgetInvestmentsHelper

  def advanced_menu_visibility
    if params[:advanced_filters].empty? &&
      params["min_total_supports"].blank? &&
      params["max_total_supports"].blank?
      "hide"
    else
      ""
    end
  end

  def init_advanced_menu
    params[:advanced_filters] = [] unless params[:advanced_filters]
  end

end
