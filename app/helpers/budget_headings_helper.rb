module BudgetHeadingsHelper
  def budget_heading_select_options(budget)
    budget.headings.sort_by_name.map do |heading|
      [heading.name_scoped_by_group, heading.id]
    end
  end

  def custom_budget_heading_select_options(budget)
    aux = []
    groups_ids = budget.investments.where(author_id: current_user.id).map(&:group_id)
    groups_allowed = budget.groups.where.not(id: groups_ids)
    groups_allowed.each do |g|
      g.headings.each do |heading|
        aux << [heading.name_scoped_by_group, heading.id]
      end
    end
    aux
  end

  def custom_geozone_select_options
    aux = []
    Geozone.all.order('created_at DESC').each do |geozone|
      aux << [geozone.name, geozone.id]
    end
    aux
  end

  def custom_sub_area_select_options(area_id)
    aux = []
    sub_areas_allowed = Area.find(area_id).sub_areas
    sub_areas_allowed.each do |sub_area|
      aux << [sub_area.name, sub_area.id]
    end
    aux
  end

  def groups_not_allowed(budget)
    groups_ids = budget.investments.where(author_id: current_user.id).map(&:group_id)
    budget.groups.where(id: groups_ids)
  end

  def heading_link(assigned_heading = nil, budget = nil)
    return nil unless assigned_heading && budget

    heading_path = budget_investments_path(budget, heading_id: assigned_heading&.id)
    link_to(assigned_heading.name, heading_path)
  end
end
