class Users::BudgetInvestmentTableActionsComponent < ApplicationComponent
  attr_reader :investment
  use_helpers :can?

  def initialize(investment)
    @investment = investment
  end
end
