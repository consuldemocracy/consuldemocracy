module AdminBudgetInvestmentsHelper

  def advanced_menu_visibility
    (params[:advanced_filters].empty? && params["min_total_supports"].blank?) ? 'hide' : ''
  end

  def init_advanced_menu
    params[:advanced_filters] = [] unless params[:advanced_filters]
  end

end
