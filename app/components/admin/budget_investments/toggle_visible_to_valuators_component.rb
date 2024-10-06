class Admin::BudgetInvestments::ToggleVisibleToValuatorsComponent < ApplicationComponent
  attr_reader :investment
  use_helpers :can?

  def initialize(investment)
    @investment = investment
  end
end
