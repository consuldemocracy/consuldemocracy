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

  context "#available?" do

    it "returns true when latitude, longitude and zoom defined" do
      expect(map_location.available?).to be(true)
    end

    it "returns false when longitude is nil" do
      map_location.longitude = nil

      expect(map_location.available?).to be(false)
    end

    it "returns false when latitude is nil" do
      map_location.latitude = nil

      expect(map_location.available?).to be(false)
    end

    it "returns false when zoom is nil" do
      map_location.zoom = nil

      expect(map_location.available?).to be(false)
    end
  end

end
