class Budgets::Executions::InvestmentsComponent < ApplicationComponent
  attr_reader :investments_by_heading

  def initialize(investments_by_heading)
    @investments_by_heading = investments_by_heading
  end
end
