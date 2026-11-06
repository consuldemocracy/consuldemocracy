class Budgets::Results::ShowComponent < ApplicationComponent
  attr_reader :budget, :heading

  def initialize(budget, heading:)
    @budget = budget
    @heading = heading
  end

  private

    def investments
      @investments ||= Budget::Result.new(budget, heading).investments
    end

    def headings
      @headings ||= @budget.headings.sort_by_name
    end
end
