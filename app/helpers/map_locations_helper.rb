module MapLocationsHelper
  def map_location_available?(map_location)
    map_location.present? && map_location.available?
  end

  def map_location_input_id(prefix, attribute)
    "#{prefix}_map_location_attributes_#{attribute}"
  end

  def render_map(...)
    render Shared::MapLocationComponent.new(...)
  end
end
