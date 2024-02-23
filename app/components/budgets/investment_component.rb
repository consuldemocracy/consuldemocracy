class Budgets::InvestmentComponent < ApplicationComponent
  use_helpers :locale_and_user_status, :namespaced_budget_investment_path, :image_path_for
  attr_reader :investment

  def initialize(investment)
    @investment = investment
  end
end
