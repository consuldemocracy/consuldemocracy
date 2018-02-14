module BudgetHeadingsHelper

  def budget_heading_select_options(budget)
    aux = []
    groups_ids = budget.investments.where(author_id: current_user.id).map(&:group_id)
    budget.groups.where.not(id: groups_ids).each do |g|
      g.headings.each do |heading|
        aux << [heading.name_scoped_by_group, heading.id]
      end
    end
    aux

    # budget.headings.order_by_group_name.map do |heading|
    #   [heading.name_scoped_by_group, heading.id]
    # end
  end

end
