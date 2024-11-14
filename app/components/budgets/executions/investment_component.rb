class Budgets::Executions::InvestmentComponent < ApplicationComponent
  attr_reader :investment

  def initialize(investment)
    @investment = investment
  end
end
