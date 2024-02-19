require "rails_helper"

describe MapLocation do
  let(:map_location) { build(:map_location, :proposal_map_location) }

  it "is valid" do
    expect(map_location).to be_valid
  end

  it "is invalid when longitude/latitude/zoom are not present" do
    map_location.longitude = nil
    map_location.latitude = nil
    map_location.zoom = nil

    expect(map_location).not_to be_valid
    expect(map_location.errors.size).to eq(6)
  end

  it "is invalid when longitude/latitude/zoom are not numbers" do
    map_location.longitude = "wadus"
    map_location.latitude = "stuff"
    map_location.zoom = "$%·"

    expect(map_location).not_to be_valid
    expect(map_location.errors.size).to eq(3)
  end

  describe "#available?" do
    it "returns true when latitude, longitude and zoom defined" do
      expect(map_location.available?).to be true
    end

    it "returns false when longitude is nil" do
      map_location.longitude = nil

      expect(map_location.available?).to be false
    end

    it "returns false when latitude is nil" do
      map_location.latitude = nil

      expect(map_location.available?).to be false
    end

    it "returns false when zoom is nil" do
      map_location.zoom = nil

      expect(map_location.available?).to be false
    end
  end

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
