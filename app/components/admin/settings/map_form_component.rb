class Admin::Settings::MapFormComponent < ApplicationComponent
  attr_reader :tab
  delegate :render_map, to: :helpers

  def initialize(tab: nil)
    @tab = tab
  end

  private

    def map_location
      MapLocation.new(
        latitude: Setting["map.latitude"],
        longitude: Setting["map.longitude"],
        zoom: Setting["map.zoom"]
      )
    end
end
