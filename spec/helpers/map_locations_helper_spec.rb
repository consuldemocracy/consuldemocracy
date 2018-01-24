require 'rails_helper'

describe MapLocationsHelper do

  describe "#clean_coordinates" do

    it "returns valid coordinates" do
      coordinates = [lat: 40.3267278, long: -3.6755274]
      expect(clean_coordinates(coordinates)).to eq([lat: 40.3267278, long: -3.6755274])
    end

    it "does not return coordinates with an invalid latitude" do
      coordinates = [lat: "********", long: -3.6755274]
      expect(clean_coordinates(coordinates)).to eq([])
    end

    it "does not return coordinates with an invalid longitude" do
      coordinates = [lat: 40.3267278, long: "********"]
      expect(clean_coordinates(coordinates)).to eq([])
    end

  end
end