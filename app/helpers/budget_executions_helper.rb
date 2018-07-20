module BudgetExecutionsHelper

  def spending_proposals?
    @budget.slug == '2016'
  end
end
