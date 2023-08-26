class Budgets::InvestmentComponent < ApplicationComponent
  delegate :locale_and_user_status, :namespaced_budget_investment_path, :image_path_for, to: :helpers
  attr_reader :investment

  def initialize(investment)
    @investment = investment
  end
end
