class Budgets::Executions::HeadingComponent < ApplicationComponent
  attr_reader :heading, :investments

  def initialize(heading, investments)
    @heading = heading
    @investments = investments
  end
end
