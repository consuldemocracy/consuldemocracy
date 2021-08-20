class Admin::BudgetInvestments::ToggleSelectionComponent < ApplicationComponent
  attr_reader :investment
  delegate :can?, to: :controller

  def initialize(investment)
    @investment = investment
  end

  private

    def budget
      investment.budget
    end
end
