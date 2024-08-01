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
    it "returns nil when geojson is nil" do
      geozone.geojson = nil
      expect(geozone.outline_points).to be(nil)
    end

    it "returns normalized feature collection when geojson is a valid FeatureCollection" do
      geozone.geojson = '{
        "type": "FeatureCollection",
        "features": [{
          "type": "Feature",
          "geometry": {
            "type": "Polygon",
            "coordinates": [[
              [-3.9259027239257, 40.8792937308316],
              [-3.9249047078766, 40.8788966596619],
              [-3.9247799675785, 40.8789131852224],
              [-3.9259027239257, 40.8792937308316]
            ]]
          }
        }]
      }'

      expected = {
        "type" => "FeatureCollection",
        "features" => [{
          "type" => "Feature",
          "geometry" => {
            "type" => "Polygon",
            "coordinates" => [[
              [-3.9259027239257, 40.8792937308316],
              [-3.9249047078766, 40.8788966596619],
              [-3.9247799675785, 40.8789131852224],
              [-3.9259027239257, 40.8792937308316]
            ]]
          },
          "properties" => {}
        }]
      }

      expect(geozone.outline_points).to eq(expected.to_json)
    end

    it "returns normalized feature collection when geojson is a valid Feature" do
      geozone.geojson = '{
        "type": "Feature",
        "geometry": {
          "type": "Polygon",
          "coordinates": [[
            [-3.9259027239257, 40.8792937308316],
            [-3.9249047078766, 40.8788966596619],
            [-3.9247799675785, 40.8789131852224],
            [-3.9259027239257, 40.8792937308316]
          ]]
        }
      }'

      expected = {
        "type" => "FeatureCollection",
        "features" => [{
          "type" => "Feature",
          "geometry" => {
            "type" => "Polygon",
            "coordinates" => [[
              [-3.9259027239257, 40.8792937308316],
              [-3.9249047078766, 40.8788966596619],
              [-3.9247799675785, 40.8789131852224],
              [-3.9259027239257, 40.8792937308316]
            ]]
          },
          "properties" => {}
        }]
      }

      expect(geozone.outline_points).to eq(expected.to_json)
    end

    it "returns normalized feature collection when geojson is a valid Geometry object" do
      geozone.geojson = '{
        "geometry": {
          "type": "Polygon",
          "coordinates": [[
            [-3.9259027239257, 40.8792937308316],
            [-3.9249047078766, 40.8788966596619],
            [-3.9247799675785, 40.8789131852224],
            [-3.9259027239257, 40.8792937308316]
          ]]
        }
      }'

      expected = {
        "type" => "FeatureCollection",
        "features" => [{
          "type" => "Feature",
          "geometry" => {
            "type" => "Polygon",
            "coordinates" => [[
              [-3.9259027239257, 40.8792937308316],
              [-3.9249047078766, 40.8788966596619],
              [-3.9247799675785, 40.8789131852224],
              [-3.9259027239257, 40.8792937308316]
            ]]
          },
          "properties" => {}
        }]
      }
      shape = JSON.parse(geozone.outline_points)
      expect(shape).to eq(expected)
    end

    it "returns normalized feature collection when geojson is a valid top-level Geometry object" do
      geozone.geojson = '{
        "type": "Polygon",
        "coordinates": [[
          [-3.9259027239257, 40.8792937308316],
          [-3.9249047078766, 40.8788966596619],
          [-3.9247799675785, 40.8789131852224],
          [-3.9259027239257, 40.8792937308316]
        ]]
      }'

      expected = {
        "type" => "FeatureCollection",
        "features" => [{
          "type" => "Feature",
          "geometry" => {
            "type" => "Polygon",
            "coordinates" => [[
              [-3.9259027239257, 40.8792937308316],
              [-3.9249047078766, 40.8788966596619],
              [-3.9247799675785, 40.8789131852224],
              [-3.9259027239257, 40.8792937308316]
            ]]
          },
          "properties" => {}
        }]
      }

      expect(geozone.outline_points).to eq(expected.to_json)
    end
  end
end
