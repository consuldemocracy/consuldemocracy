class Budgets::Investments::InfoComponent < ApplicationComponent
  attr_reader :investment

  def initialize(investment)
    @investment = investment
  end
end
