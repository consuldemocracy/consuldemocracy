class Budget::VotingStyles::Knapsack < Budget::VotingStyles::Base
  def enough_resources?(investment)
    investment.price.to_i <= amount_available(investment.heading)
  end

  def reason_for_not_being_ballotable(investment)
    :not_enough_money unless enough_resources?(investment)
  end

  def not_enough_resources_error
    "insufficient funds"
  end

  def amount_spent(heading)
    investments_price(heading)
  end

  def amount_limit(heading)
    ballot.budget.heading_price(heading)
  end

  def format(amount)
    ballot.budget.formatted_amount(amount)
  end
end
