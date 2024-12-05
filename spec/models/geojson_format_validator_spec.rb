require "rails_helper"

describe GeojsonFormatValidator do
  before do
    dummy_model = Class.new do
      include ActiveModel::Model
      attr_accessor :geojson
      validates :geojson, geojson_format: true
    end

    stub_const("DummyModel", dummy_model)
  end

  let(:record) { DummyModel.new }

  it "is not valid with an empty hash" do
    record.geojson = "{}"

    expect(record).not_to be_valid
  end

  it "is not valid with arbitrary keys" do
    record.geojson = '{ "invalid": "yes" }'

    expect(record).not_to be_valid
  end

  it "is not valid without a type" do
    record.geojson = '{ "coordinates": [1.23, 4.56] }'

    expect(record).not_to be_valid
  end

  it "is not valid without a type but a geometry" do
    record.geojson = '{ "geometry": { "type": "Point", "coordinates": [1.23, 4.56] } }'

    expect(record).not_to be_valid
  end

  context "Point geometry" do
    it "is not valid without coordinates" do
      record.geojson = '{ "type": "Point" }'

      expect(record).not_to be_valid
    end

    it "is not valid with only one the longitude" do
      record.geojson = '{ "type": "Point", "coordinates": 1.23 }'

      expect(record).not_to be_valid
    end

    it "is not valid with non-numerical coordinates" do
      record.geojson = '{ "type": "Point", "coordinates": ["1.23", "4.56"] }'

      expect(record).not_to be_valid
    end

    it "is not valid with 3-dimensional coordinates" do
      record.geojson = '{ "type": "Point", "coordinates": [1.23, 4.56, 7.89] }'

      expect(record).not_to be_valid
    end

    it "is not valid with multiple coordinates" do
      record.geojson = '{ "type": "Point", "coordinates": [[1.23, 4.56], [7.89, 10.11]] }'

      expect(record).not_to be_valid
    end

    it "is not valid with a longitude above 180" do
      record.geojson = '{ "type": "Point", "coordinates": [180.01, 4.56] }'

      expect(record).not_to be_valid
    end

    it "is not valid with a longitude below -180" do
      record.geojson = '{ "type": "Point", "coordinates": [-180.01, 4.56] }'

      expect(record).not_to be_valid
    end

    it "is not valid with a latitude above 90" do
      record.geojson = '{ "type": "Point", "coordinates": [1.23, 90.01] }'

      expect(record).not_to be_valid
    end

    it "is not valid with a latitude below -90" do
      record.geojson = '{ "type": "Point", "coordinates": [1.23, -90.01] }'

      expect(record).not_to be_valid
    end

    it "is valid with coordinates in the valid range" do
      record.geojson = '{ "type": "Point", "coordinates": [1.23, 4.56] }'

      expect(record).to be_valid
    end

    it "is valid with coordinates at the positive end of the range" do
      record.geojson = '{ "type": "Point", "coordinates": [180.0, 90.0] }'

      expect(record).to be_valid
    end

    it "is valid with coordinates at the negative end of the range" do
      record.geojson = '{ "type": "Point", "coordinates": [-180.0, -90.0] }'

      expect(record).to be_valid
    end
  end

  context "LineString or MultiPoint geometry" do
    it "is not valid with a one-dimensional array of coordinates" do
      record.geojson = '{ "type": "LineString", "coordinates": [1.23, 4.56] }'

      expect(record).not_to be_valid

      record.geojson = '{ "type": "MultiPoint", "coordinates": [1.23, 4.56] }'

      expect(record).not_to be_valid
    end

    it "is not valid when some coordinates are invalid" do
      record.geojson = '{ "type": "LineString", "coordinates": [[1.23, 4.56], [180.01, 4.56]] }'

      expect(record).not_to be_valid

      record.geojson = '{ "type": "MultiPoint", "coordinates": [[1.23, 4.56], [180.01, 4.56]] }'

      expect(record).not_to be_valid
    end

    it "is valid when all the coordinates are valid" do
      record.geojson = '{ "type": "LineString", "coordinates": [[1.23, 4.56], [7.89, 4.56]] }'

      expect(record).to be_valid

      record.geojson = '{ "type": "MultiPoint", "coordinates": [[1.23, 4.56], [7.89, 4.56]] }'

      expect(record).to be_valid
    end
  end

  context "LineString geometry" do
    it "is not valid with only one point" do
      record.geojson = '{ "type": "LineString", "coordinates": [[1.23, 4.56]] }'

      expect(record).not_to be_valid
    end
  end

  context "MultiPoint geometry" do
    it "is valid with only one point" do
      record.geojson = '{ "type": "MultiPoint", "coordinates": [[1.23, 4.56]] }'

      expect(record).to be_valid
    end
  end

  context "Polygon or MultiLineString geometry" do
    it "is not valid with a one-dimensional array of coordinates" do
      record.geojson = '{ "type": "MultiLineString", "coordinates": [1.23, 4.56] }'

      expect(record).not_to be_valid

      record.geojson = '{ "type": "Polygon", "coordinates": [1.23, 4.56] }'

      expect(record).not_to be_valid
    end

    it "is not valid with a two-dimensional array of coordinates" do
      record.geojson = '{ "type": "MultiLineString", "coordinates": [[1.23, 4.56], [7.89, 4.56]] }'

      expect(record).not_to be_valid

      record.geojson = '{ "type": "Polygon", "coordinates": [[1.23, 4.56], [7.89, 4.56]] }'

      expect(record).not_to be_valid
    end
  end

  context "MultiLineString geometry" do
    it "is valid with just one line" do
      record.geojson = '{ "type": "MultiLineString", "coordinates": [[[1.23, 4.56], [7.89, 4.56]]] }'

      expect(record).to be_valid
    end

    it "is valid with multiple valid lines" do
      record.geojson = <<~JSON
        {
          "type": "MultiLineString",
          "coordinates": [
            [[1.23, 4.56], [7.89, 4.56]],
            [[10.11, 12.13], [14.15, 16.17]]
          ]
        }
      JSON

      expect(record).to be_valid
    end

    it "is not valid if some lines are invalid" do
      record.geojson = <<~JSON
        {
          "type": "MultiLineString",
          "coordinates": [
            [[1.23, 4.56], [7.89, 4.56]],
            [[10.11, 12.13]]
          ]
        }
      JSON

      expect(record).not_to be_valid
    end
  end

  context "Polygon geometry" do
    it "is not valid with a ring having less than four elements" do
      record.geojson = <<~JSON
        {
          "type": "Polygon",
          "coordinates": [[
            [1.23, 4.56],
            [7.89, 10.11],
            [1.23, 4.56]
          ]]
        }
      JSON

      expect(record).not_to be_valid
    end

    it "is not valid with a ring which with different starting and end points" do
      record.geojson = <<~JSON
        {
          "type": "Polygon",
          "coordinates": [[
            [1.23, 4.56],
            [7.89, 10.11],
            [12.13, 14.15],
            [16.17, 18.19]
          ]]
        }
      JSON

      expect(record).not_to be_valid
    end

    it "is valid with one valid ring" do
      record.geojson = <<~JSON
        {
          "type": "Polygon",
          "coordinates": [[
            [1.23, 4.56],
            [7.89, 10.11],
            [12.13, 14.15],
            [1.23, 4.56]
          ]]
        }
      JSON

      expect(record).to be_valid
    end

    it "is valid with multiple valid rings" do
      record.geojson = <<~JSON
        {
          "type": "Polygon",
          "coordinates": [
            [
              [100.0, 0.0],
              [101.0, 0.0],
              [101.0, 1.0],
              [100.0, 1.0],
              [100.0, 0.0]
            ],
            [
              [100.8, 0.8],
              [100.8, 0.2],
              [100.2, 0.2],
              [100.2, 0.8],
              [100.8, 0.8]
            ]
          ]
        }
      JSON

      expect(record).to be_valid
    end

    it "is not valid with multiple rings if some rings are invalid" do
      record.geojson = <<~JSON
        {
          "type": "Polygon",
          "coordinates": [
            [
              [100.0, 0.0],
              [101.0, 0.0],
              [101.0, 1.0],
              [100.0, 1.0],
              [100.0, 0.0]
            ],
            [
              [100.8, 0.8],
              [100.8, 0.2],
              [100.2, 0.2]
            ]
          ]
        }
      JSON

      expect(record).not_to be_valid
    end
  end

  context "MultiPolygon geometry" do
    it "is not valid with a one-dimensional array of coordinates" do
      record.geojson = '{ "type": "MultiPolygon", "coordinates": [1.23, 4.56] }'

      expect(record).not_to be_valid
    end

    it "is not valid with a two-dimensional array of coordinates" do
      record.geojson = '{ "type": "MultiPolygon", "coordinates": [[1.23, 4.56], [7.89, 4.56]] }'

      expect(record).not_to be_valid
    end

    it "is not valid with a three-dimensional polygon coordinates array" do
      record.geojson = <<~JSON
        {
          "type": "MultiPolygon",
          "coordinates": [[
            [1.23, 4.56],
            [7.89, 10.11],
            [12.13, 14.15],
            [1.23, 4.56]
          ]]
        }
      JSON

      expect(record).not_to be_valid
    end

    it "is valid with a valid polygon" do
      record.geojson = <<~JSON
        {
          "type": "MultiPolygon",
          "coordinates": [[[
            [1.23, 4.56],
            [7.89, 10.11],
            [12.13, 14.15],
            [1.23, 4.56]
          ]]]
        }
      JSON

      expect(record).to be_valid
    end

    it "is valid with multiple valid polygons" do
      record.geojson = <<~JSON
        {
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [1.23, 4.56],
                [7.89, 10.11],
                [12.13, 14.15],
                [1.23, 4.56]
              ]
            ],
            [
              [
                [100.0, 0.0],
                [101.0, 0.0],
                [101.0, 1.0],
                [100.0, 1.0],
                [100.0, 0.0]
              ],
              [
                [100.8, 0.8],
                [100.8, 0.2],
                [100.2, 0.2],
                [100.2, 0.8],
                [100.8, 0.8]
              ]
            ]
          ]
        }
      JSON

      expect(record).to be_valid
    end

    it "is not valid with multiple polygons if some polygons are invalid" do
      record.geojson = <<~JSON
        {
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [1.23, 4.56],
                [7.89, 10.11],
                [12.13, 14.15],
                [1.23, 4.56]
              ]
            ],
            [
              [
                [100.0, 0.0],
                [101.0, 0.0],
                [101.0, 1.0],
                [100.0, 1.0],
                [100.0, 0.0]
              ],
              [
                [100.8, 0.8],
                [100.8, 0.2],
                [100.2, 0.2]
              ]
            ]
          ]
        }
      JSON

      expect(record).not_to be_valid
    end
  end

  context "GeometryCollection" do
    it "is not valid if it doesn't contain geometries" do
      record.geojson = '{ "type": "GeometryCollection" }'

      expect(record).not_to be_valid
    end

    it "is not valid if geometries is not an array" do
      record.geojson = <<~JSON
        {
          "type": "GeometryCollection",
          "geometries": { "type": "Point", "coordinates": [1.23, 4.56] }
        }
      JSON

      expect(record).not_to be_valid
    end

    it "is valid if the array of geometries is empty" do
      record.geojson = '{ "type": "GeometryCollection", "geometries": [] }'

      expect(record).to be_valid
    end

    it "is valid if all geometries are valid" do
      record.geojson = <<~JSON
        {
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Point",
              "coordinates": [100.0, 0.0]
            },
            {
              "type": "LineString",
              "coordinates": [
                [101.0, 0.0],
                [102.0, 1.0]
              ]
            }
          ]
        }
      JSON

      expect(record).to be_valid
    end

    it "is not valid if some geometries are invalid" do
      record.geojson = <<~JSON
        {
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Point",
              "coordinates": [100.0, 0.0]
            },
            {
              "type": "LineString",
              "coordinates": [101.0, 0.0]
            }
          ]
        }
      JSON

      expect(record).not_to be_valid
    end
  end

  context "Feature" do
    it "is valid with a valid geometry" do
      record.geojson = <<~JSON
        {
          "type": "Feature",
          "geometry": {
            "type": "Point",
            "coordinates": [1.23, 4.56]
          }
        }
      JSON

      expect(record).to be_valid
    end

    it "is not valid with a valid geometry" do
      record.geojson = <<~JSON
        {
          "type": "Feature",
          "geometry": {
            "type": "Point",
            "coordinates": [1.23]
          }
        }
      JSON

      expect(record).not_to be_valid
    end
  end

  context "FeatureCollection" do
    it "is not valid without features" do
      record.geojson = '{ "type": "FeatureCollection" }'
    end

    it "is not valid if features is not an array" do
      record.geojson = <<~JSON
        {
          "type": "FeatureCollection",
          "features": {
            "type": "Feature",
            "geometry": {
              "type": "Point",
              "coordinates": [1.23, 4.56]
            }
          }
        }
      JSON
    end

    it "is valid if the array of features is empty" do
      record.geojson = '{ "type": "FeatureCollection", "features": [] }'

      expect(record).to be_valid
    end

    it "is valid if all features are valid" do
      record.geojson = <<~JSON
        {
          "type": "FeatureCollection",
          "features": [
            {
              "type": "Feature",
              "geometry": {
                "type": "Point",
                "coordinates": [1.23, 4.56]
              }
            },
            {
              "type": "Feature",
              "geometry": {
                "type": "LineString",
                "coordinates": [[101.0, 0.0], [102.0, 1.0]]
              }
            }
          ]
        }
      JSON

      expect(record).to be_valid
    end

    it "is not valid if some features are invalid" do
      record.geojson = <<~JSON
        {
          "type": "FeatureCollection",
          "features": [
            {
              "type": "Feature",
              "geometry": {
                "type": "Point",
                "coordinates": [1.23, 4.56]
              }
            },
            {
              "type": "LineString",
              "coordinates": [[101.0, 0.0], [102.0, 1.0]]
            }
          ]
        }
      JSON

      expect(record).not_to be_valid
    end
  end
end
