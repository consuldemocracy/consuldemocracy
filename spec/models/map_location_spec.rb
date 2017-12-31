require 'rails_helper'

describe MapLocation do

  let(:map_location) { build(:map_location, :proposal_map_location) }

  it "should be valid" do
    expect(map_location).to be_valid
  end

  context "#available?" do

    it "should return true when latitude, longitude and zoom defined" do
      expect(map_location.available?).to be(true)
    end

    it "should return false when longitude is nil" do
      map_location.longitude = nil

      expect(map_location.available?).to be(false)
    end

    it "should return false when latitude is nil" do
      map_location.latitude = nil

      expect(map_location.available?).to be(false)
    end

    it "should return false when zoom is nil" do
      map_location.zoom = nil

      expect(map_location.available?).to be(false)
    end
  end

end
