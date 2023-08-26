class Budgets::Investments::MapComponent < ApplicationComponent
  attr_reader :heading, :investments
  delegate :render_map, to: :helpers

  def initialize(investments, heading:)
    @investments = investments
    @heading = heading
  end

  def render?
    map_location&.available?
  end

  private

    def map_location
      MapLocation.from_heading(heading) if heading.present?
    end

    def coordinates
      MapLocation.investments_json_data(investments.unscope(:order))
    end

    def geozones_data
      return unless heading.geozone.present?

      [
        {
          outline_points: heading.geozone.outline_points,
          color: heading.geozone.color
        }
      ]
    end
end
