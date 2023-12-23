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
    else
      budget.investments.none
    end
  end

  def see_all_path
    if budget.single_heading?
      budget_investments_path(budget)
    else
      budget_groups_path(budget)
    end
  end
end
