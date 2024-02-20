require_dependency Rails.root.join("app", "models", "map_location").to_s

class MapLocation
  def from_map(map)
    self.latitude = map.map_location.latitude
    self.longitude = map.map_location.longitude
    self.zoom = map.map_location.zoom
    self
  end

  def self.default_latitude
    51.48
  end

  def self.default_longitude
    0.0
  end

  def self.default_zoom
    10
  end
end
