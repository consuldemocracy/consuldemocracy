class Admin::Settings::MapFormComponent < ApplicationComponent
  attr_reader :tab
  use_helpers :render_map

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
