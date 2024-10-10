module MapLocationsHelper
  def map_location_available?(map_location)
    map_location.present? && map_location.available?
  end

  def render_map(...)
    render Shared::MapLocationComponent.new(...)
  end
end
