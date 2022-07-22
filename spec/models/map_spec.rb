require "rails_helper"

describe Map do
  let(:map) { build(:map) }

  it "is valid" do
    expect(map).to be_valid
  end

  it "is invalid when budget_id is taken" do
    existing_map = create(:map)

    map.budget_id = existing_map.budget_id
    expect(map).not_to be_valid
  end

  describe "#default?" do
    it "returns true if it is the default map" do
      expect(Map.default.default?).to be true
      expect(map.default?).to be false
    end
  end

  describe "#set_default_map_location" do
    it "sets the default coordinates for the default map" do
      map = Map.default
      map.map_location.destroy!

      expect(map.reload.map_location).to be nil
      expect(MapLocation.count).to be 0

      map.set_default_map_location

      expect(Map.count).to be 1
      expect(MapLocation.count).to be 1

      expect(map.map_location.latitude).to eq MapLocation.default_latitude
      expect(map.map_location.longitude).to eq MapLocation.default_longitude
      expect(map.map_location.zoom).to eq MapLocation.default_zoom
    end

    it "does not set the default coordinates for other maps" do
      map = create(:map)
      expect(map.map_location).to be nil

      map.set_default_map_location
      expect(map.map_location).to be nil
    end
  end

  describe ".default" do
    it "returns the default map if it is already created" do
      expect(Map.count).to be 1
      expect(MapLocation.count).to be 1

      expect(Map.default).to eq Map.first
      expect(Map.default.map_location).to eq MapLocation.first
    end

    it "creates and returns the default map if it is not created yet" do
      MapLocation.destroy_all
      Map.destroy_all

      expect(Map.count).to be 0
      expect(MapLocation.count).to be 0

      expect(Map.default).to be_a(Map)

      expect(Map.count).to be 1
      expect(MapLocation.count).to be 1

      expect(Map.first.budget_id).to be 0
      expect(MapLocation.first.latitude).to eq MapLocation.default_latitude
      expect(MapLocation.first.longitude).to eq MapLocation.default_longitude
      expect(MapLocation.first.zoom).to eq MapLocation.default_zoom
    end
  end
end
