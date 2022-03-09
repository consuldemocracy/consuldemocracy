module BudgetExecutionsHelper
  def first_milestone_with_image(investment)
    investment.milestones.order_by_publication_date
                         .select { |milestone| milestone.image.present? }.last
  end
end
