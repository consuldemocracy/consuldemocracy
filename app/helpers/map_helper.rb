module MapHelper
  def map_budget_name(budget_id)
    if budget_id == 0
      t("admin.maps.index.default_map")
    else
      Budget.find_by(id: budget_id)&.name
    end
  end

  def budget_select_options
    budgets_with_map = Map.all.map(&:budget_id)
    Budget.where.not(id: budgets_with_map).order(id: :desc).map do |budget|
      [budget.name, budget.id]
    end
  end
end
