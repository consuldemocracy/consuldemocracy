class Budgets::MapComponent < ApplicationComponent
  delegate :render_map, to: :helpers
  attr_reader :budget

  def initialize(budget)
    @budget = budget
  end

  def render?
    feature?(:map) && !budget.informing?
  end

  private

    def coordinates
      if budget.publishing_prices_or_later? && budget.investments.selected.any?
        investments = budget.investments.selected
      else
        investments = budget.investments
      end

      MapLocation.where(investment_id: investments).map(&:json_data)
    end
end
