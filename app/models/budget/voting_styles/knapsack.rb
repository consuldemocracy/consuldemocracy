class Budget::VotingStyles::Knapsack < Budget::VotingStyles::Base
  def enough_money?(investment)
    investment.price.to_i <= amount_available(investment.heading)
  end

  def amount_available(heading)
    amount_limit(heading) - amount_spent(heading)
  end

  def amount_spent(heading)
    investments_price(heading)
  end

  def amount_limit(heading)
    ballot.budget.heading_price(heading)
  end

  def formatted_amount_available(heading)
    format(amount_available(heading))
  end

  def formatted_amount_spent(heading)
    format(amount_spent(heading))
  end

  def formatted_amount_limit(heading)
    format(amount_limit(heading))
  end

  def format(amount)
    ballot.budget.formatted_amount(amount)
  end
end
