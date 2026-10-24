class Budgets::Results::ShowComponent < ApplicationComponent
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  private

    def investments
      @investments ||= Budget::Result.new(budget, heading).investments
    end

    def headings
      @headings ||= @budget.headings.sort_by_name
    end

    def heading
      @heading ||= @budget.headings.find_by_slug_or_id(params[:heading_id]) || @budget.headings.first
    end
end
