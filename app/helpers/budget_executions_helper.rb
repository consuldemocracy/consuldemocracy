module BudgetExecutionsHelper

  def spending_proposals?
    @budget.slug == '2016'
  end

  def filters_select_counts(status)
    @budget.investments.winners.with_milestones.select { |i| i.milestones
                                      .published.with_status.order_by_publication_date
                                      .last.status_id == status rescue false }.count
  end

  def first_milestone_with_image(investment)
    investment.milestones.order(publication_date: :asc, created_at: :asc)
                         .select{ |milestone| milestone.image.present? }.first
  end

end
