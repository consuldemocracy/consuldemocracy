class GeojsonFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present?
      geojson = parse_json(value)

      unless valid_geojson?(geojson)
        record.errors.add(attribute, :invalid)
        return
      end

      unless valid_coordinates?(geojson)
        record.errors.add(attribute, :invalid_coordinates)
      end
    end
  end

  private

    def parse_json(geojson_data)
      JSON.parse(geojson_data)
    rescue JSON::ParserError
      nil
    end

    def valid_geojson?(geojson)
      return false unless geojson.is_a?(Hash)

      if geojson["type"] == "FeatureCollection"
        valid_feature_collection?(geojson)
      elsif geojson["type"] == "Feature"
        valid_feature?(geojson)
      else
        valid_geometry?(geojson)
      end
    end

    def valid_feature_collection?(geojson)
      return false unless geojson["features"].is_a?(Array)

      geojson["features"].all? { |feature| valid_feature?(feature) }
    end

    def valid_feature?(feature)
      feature["type"] == "Feature" && valid_geometry?(feature["geometry"])
    end

    def valid_geometry?(geometry)
      geometry.is_a?(Hash) && valid_geometry_types.include?(geometry["type"])
    end

    def valid_geometry_types
      [
        "Point", "LineString", "Polygon", "MultiPoint", "MultiLineString", "MultiPolygon",
        "GeometryCollection"
      ]
    end

    def valid_coordinates?(geojson)
      if geojson["type"] == "FeatureCollection"
        geojson["features"].all? { |feature| valid_coordinates?(feature) }
      elsif geojson["type"] == "Feature"
        valid_geometry_coordinates?(geojson["geometry"])
      else
        valid_geometry_coordinates?(geojson)
      end
    end

    def valid_geometry_coordinates?(geometry)
      if geometry["type"] == "GeometryCollection"
        geometries = geometry["geometries"]

        return geometries.is_a?(Array) && geometries.all? { |geom| valid_geometry_coordinates?(geom) }
      end

      coordinates = geometry["coordinates"]

      return false unless coordinates.is_a?(Array)

      case geometry["type"]
      when "Point"
        valid_wgs84_coordinates?(coordinates)
      when "LineString"
        valid_linestring_coordinates?(coordinates)
      when "MultiPoint"
        valid_coordinates_array?(coordinates)
      when "MultiLineString"
        coordinates.all? do |linestring_coordinates|
          valid_linestring_coordinates?(linestring_coordinates)
        end
      when "Polygon"
        valid_polygon_coordinates?(coordinates)
      when "MultiPolygon"
        coordinates.all? do |polygon_coordinates|
          valid_polygon_coordinates?(polygon_coordinates)
        end
      else
        false
      end
    end

    def valid_wgs84_coordinates?(coordinates)
      return false unless coordinates.is_a?(Array) && coordinates.size == 2

      longitude, latitude = coordinates
      (-180.0..180.0).include?(longitude) && (-90.0..90.0).include?(latitude)
    end

    def valid_coordinates_array?(coordinates_array)
      coordinates_array.is_a?(Array) &&
        coordinates_array.all? { |coordinates| valid_wgs84_coordinates?(coordinates) }
    end

    def valid_linestring_coordinates?(coordinates)
      valid_coordinates_array?(coordinates) && coordinates.many?
    end

    def valid_polygon_coordinates?(polygon_coordinates)
      polygon_coordinates.is_a?(Array) &&
        polygon_coordinates.all? { |ring_coordinates| valid_ring_coordinates?(ring_coordinates) }
    end

    def valid_ring_coordinates?(ring_coordinates)
      valid_coordinates_array?(ring_coordinates) &&
        ring_coordinates.size >= 4 &&
        ring_coordinates.first == ring_coordinates.last
    end
end
