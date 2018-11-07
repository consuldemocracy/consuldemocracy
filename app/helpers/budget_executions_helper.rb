module BudgetExecutionsHelper

  def filters_select_counts(status)
    @budget.investments.winners.with_milestones.select { |i| i.milestones
                                      .published.with_status.order_by_publication_date
                                      .last.status_id == status rescue false }.count
  end

  def first_milestone_with_image(investment)
    investment.milestones.order_by_publication_date
                         .select{ |milestone| milestone.image.present? }.last
  end

end
