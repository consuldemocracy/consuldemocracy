module Shared
  class MapComponent < ApplicationComponent
    attr_reader :heading, :items
    delegate :render_map, to: :helpers

    def initialize(items, heading:)
      @items = items
      @heading = heading
      Rails.logger.info "Initialized MapComponent with heading: #{heading} and items: #{items.inspect}"
    end

    def render?
      available = map_location&.available?
      Rails.logger.info "Render check: map_location available? #{available}"
      available
    end

    private

      def map_location
        if heading.present?
          location = MapLocation.from_heading(heading)
          Rails.logger.info "Map location from heading: #{location.inspect}"
          location
        end
      end

      def coordinates
        data = MapLocation.items_json_data(items.unscope(:order))
        Rails.logger.info "Coordinates data: #{data.inspect}"
        data
      end

      def geozones_data
        if heading.geozone.blank?
          Rails.logger.info "Geozone is blank"
          return
        end

        data = [
          {
            outline_points: heading.geozone.outline_points,
            color: heading.geozone.color
          }
        ]
        Rails.logger.info "Geozones data: #{data.inspect}"
        data
      end
  end
end
