require "rails_helper"

describe MapLocation do
  describe "#from_map" do
    let(:map) { Map.default }

    it "sets the coordinates from the given map location" do
      new_map_location = MapLocation.new
      expect(new_map_location.latitude).not_to eq map.map_location.latitude
      expect(new_map_location.longitude).not_to eq map.map_location.longitude
      expect(new_map_location.zoom).not_to eq map.map_location.zoom

      new_map_location = new_map_location.from_map(map)
      expect(new_map_location.latitude).to eq map.map_location.latitude
      expect(new_map_location.longitude).to eq map.map_location.longitude
      expect(new_map_location.zoom).to eq map.map_location.zoom
    end

    it "returns the same object" do
      map_location = MapLocation.create!(latitude:  MapLocation.default_latitude,
                                         longitude: MapLocation.default_longitude,
                                         zoom:      MapLocation.default_zoom)
      expect(map_location.from_map(Map.default)).to be map_location
      expect(map_location.from_map(Map.default)).not_to be Map.default.map_location
    end
  end
end
