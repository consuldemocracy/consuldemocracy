class Budgets::MapComponent < ApplicationComponent
  use_helpers :render_map
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

      MapLocation.investments_json_data(investments)
    end

    def geozones_data
      budget.geozones.map do |geozone|
        {
          outline_points: geozone.outline_points,
          color: geozone.color,
          headings: geozone_headings(geozone).map do |heading|
            link_to heading.name, budget_investments_path(budget, heading_id: heading.id)
          end,
          name: geozone_headings(geozone).map(&:name).join(", ")
        }
      end
    end

    def geozone_headings(geozone)
      budget.headings.where(geozone: geozone)
    end
end
