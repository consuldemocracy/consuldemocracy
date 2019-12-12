module BudgetExecutionsHelper
  def filters_select_counts(status)
    @budget.investments.winners.with_milestone_status_id(status).count
  end

  def options_for_milestone_tags
    @budget.investments_milestone_tags.map do |tag|
      ["#{tag} (#{@budget.investments.winners.tagged_with(tag).count})", tag]
    end
  end

  def first_milestone_with_image(investment)
    investment.milestones.order_by_publication_date
                         .select { |milestone| milestone.image.present? }.last
  end
end
