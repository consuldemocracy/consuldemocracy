require "rails_helper"

describe GeozoneStats do
  let(:winterfell) { create(:geozone, name: "Winterfell") }
  let(:riverlands) { create(:geozone, name: "Riverlands") }

  describe "#name" do
    let(:stats) { GeozoneStats.new(winterfell, []) }

    it "returns the geozone name" do
      expect(stats.name).to eq "Winterfell"
    end
  end

  describe "#count" do
    before do
      2.times { create(:user, geozone: winterfell) }
      1.times { create(:user, geozone: riverlands) }
    end

    let(:winterfell_stats) { GeozoneStats.new(winterfell, User.all) }
    let(:riverlands_stats) { GeozoneStats.new(riverlands, User.all) }

    it "counts participants from the geozone" do
      expect(winterfell_stats.count).to eq 2
      expect(riverlands_stats.count).to eq 1
    end
  end

  describe "#percentage" do
    before do
      2.times { create(:user, geozone: winterfell) }
      1.times { create(:user, geozone: riverlands) }
    end

    let(:winterfell_stats) { GeozoneStats.new(winterfell, User.all) }
    let(:riverlands_stats) { GeozoneStats.new(riverlands, User.all) }

    it "calculates percentage relative to the amount of participants" do
      expect(winterfell_stats.percentage).to eq 66.667
      expect(riverlands_stats.percentage).to eq 33.333
    end
  end
end
