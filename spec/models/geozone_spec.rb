require "rails_helper"

describe Geozone do
  let(:geozone) { build(:geozone) }

  it "is valid" do
    expect(geozone).to be_valid
  end

  it "is not valid without a name" do
    geozone.name = nil
    expect(geozone).not_to be_valid
  end

  it "is valid without geojson" do
    geozone.geojson = nil
    expect(geozone).to be_valid
  end

  it "is not valid with invalid geojson file format" do
    geozone.geojson = '{"geo\":{"type":"Incorrect key","coordinates": [
                                 [40.8792937308316, -3.9259027239257],
                                 [40.8788966596619, -3.9249047078766],
                                 [40.8789131852224, -3.9247799675785]]}}'
    expect(geozone).not_to be_valid
  end

  describe "#safe_to_destroy?" do
    let(:geozone) { create(:geozone) }

    it "is true when not linked to other models" do
      expect(geozone).to be_safe_to_destroy
    end

    it "is false when already linked to user" do
      create(:user, geozone: geozone)
      expect(geozone).not_to be_safe_to_destroy
    end

    it "is false when already linked to proposal" do
      create(:proposal, geozone: geozone)
      expect(geozone).not_to be_safe_to_destroy
    end

    it "is false when already linked to debate" do
      create(:debate, geozone: geozone)
      expect(geozone).not_to be_safe_to_destroy
    end

    it "is false when already linked to a heading" do
      create(:budget_heading, geozone: geozone)
      expect(geozone).not_to be_safe_to_destroy
    end
  end

  describe "#outline_points" do
    it "returns empty array when geojson is nil" do
      expect(geozone.outline_points).to eq([])
    end

    it "returns coordinates array when geojson is not nil" do
      geozone = build(:geozone, geojson: '{
        "geometry": {
          "type": "Polygon",
          "coordinates": [
            [40.8792937308316, -3.9259027239257],
            [40.8788966596619, -3.9249047078766],
            [40.8789131852224, -3.9247799675785]
          ]
        }
      }')

      expect(geozone.outline_points).to eq(
        [[-3.9259027239257, 40.8792937308316],
         [-3.9249047078766, 40.8788966596619],
         [-3.9247799675785, 40.8789131852224]])
    end
  end
end
