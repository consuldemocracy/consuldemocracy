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

  def admin_select_options(budget)
    budget.administrators.with_user.map { |v| [v.description_or_name, v.id] }.sort_by { |a| a[0] }
  end

  def valuator_or_group_select_options(budget)
    valuator_group_select_options + valuator_select_options(budget)
  end

  def valuator_select_options(budget)
    budget.valuators.order("description ASC").order("users.email ASC").includes(:user).
      map { |v| [v.description_or_email, "valuator_#{v.id}"] }
  end

  def valuator_group_select_options
    ValuatorGroup.order("name ASC").map { |g| [g.name, "group_#{g.id}"] }
  end

  def investment_tags_select_options(budget, context)
    budget.investments.tags_on(context).order(:name).pluck(:name)
  end
end
