module BudgetExecutionsHelper

  def filters_select_counts(status)
    @budget.investments.winners.with_milestones.select do |investment|
      investment.milestone_status_id == status
    end.count
  end

  def first_milestone_with_image(investment)
    investment.milestones.order_by_publication_date
                         .select{ |milestone| milestone.image.present? }.last
  end

end
