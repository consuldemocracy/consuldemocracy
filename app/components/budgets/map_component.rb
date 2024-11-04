module Budgets
  class MapComponent < Shared::MapComponent
    attr_reader :budget

    def initialize(budget)
      @budget = budget
      items = budget.investments
      heading = budget.headings.first # Adjust this as needed
      super(items, heading: heading)
      Rails.logger.info "Initialized Budgets::MapComponent with budget: #{budget.inspect}"
    end

    def render?
      feature_enabled = feature?(:map)
      informing = budget.informing?
      Rails.logger.info "Render check: feature_enabled? #{feature_enabled}, budget.informing? #{informing}"
      feature_enabled && !informing
    end

    private

      def coordinates
        investments = if budget.publishing_prices_or_later? && budget.investments.selected.any?
                        budget.investments.selected
                      else
                        budget.investments
                      end

        data = MapLocation.investments_json_data(investments)
        Rails.logger.info "Coordinates data: #{data.inspect}"
        data
      end

      def geozones_data
        Rails.logger.info "Debugging Geozones data starting here #{budget.id}"
        data = budget.geozones.map do |geozone|
          {
            outline_points: geozone.outline_points,
            color: geozone.color,
            headings: budget.headings.where(geozone: geozone).map do |heading|
              link_to heading.name, budget_investments_path(budget, heading_id: heading.id)
            end
          }
        end
        Rails.logger.info "Geozones data: #{data.inspect}"
        data
      end
  end
end
