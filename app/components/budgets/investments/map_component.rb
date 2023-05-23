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
      MapLocation.where(investment: investments).map(&:json_data)
    end
end
