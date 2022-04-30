class Budgets::InvestmentsListComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  def investments(limit: 9)
    case budget.phase
    when "accepting", "reviewing"
      budget.investments.sample(limit)
    when "selecting", "valuating", "publishing_prices"
      budget.investments.feasible.sample(limit)
    when "balloting", "reviewing_ballots"
      budget.investments.selected.sample(limit)
    when "finished"
      budget.investments.winners.sample(limit)
    else
      budget.investments.none
    end
  end
end
