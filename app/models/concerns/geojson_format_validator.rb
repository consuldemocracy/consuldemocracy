class GeojsonFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present?
      geojson = parse_json(value)
      unless valid_geojson?(geojson)
        record.errors.add(
          attribute,
          :invalid,
          message: I18n.t("errors.geozone.attributes.geojson.invalid")
        )
        return
      end

      # Validate coordinates if the GeoJSON is valid
      if geojson["type"] == "FeatureCollection"
        geojson["features"].each do |feature|
          unless valid_coordinates?(feature["geometry"])
            record.errors.add(
              attribute,
              :invalid_coordinates,
              message: I18n.t("errors.geozone.attributes.geojson.invalid_coordinates")
            )
          end
        end
      elsif geojson["type"] == "Feature"
        unless valid_coordinates?(geojson["geometry"])
          record.errors.add(
            attribute,
            :invalid_coordinates,
            message: I18n.t("errors.geozone.attributes.geojson.invalid_coordinates")
          )
        end
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

      if geojson["type"]
        case geojson["type"]
        when "FeatureCollection"
          valid_feature_collection?(geojson)
        when "Feature"
          valid_feature?(geojson)
        else
          valid_geometry?(geojson)
        end
      else
        # Check if it is a top-level geometry object
        geojson["geometry"] && valid_geometry?(geojson["geometry"])
      end
    end

    def valid_feature_collection?(geojson)
      return false unless geojson["features"].is_a?(Array)

      geojson["features"].all? do |feature|
        valid_feature?(feature)
      end
    end

    def valid_feature?(feature)
      return false unless feature["type"] == "Feature"
      return false unless feature["geometry"].is_a?(Hash)
      return false unless valid_geometry?(feature["geometry"])

      true
    end

    def valid_geometry?(geometry)
      valid_geometry_types = [
        "Point", "LineString", "Polygon",
        "MultiPoint", "MultiLineString", "MultiPolygon",
        "GeometryCollection"
      ]

      return false unless valid_geometry_types.include?(geometry["type"])
      return false unless geometry["coordinates"].is_a?(Array)

      # Additional checks can be added for specific geometry types if needed
      true
    end

    def valid_coordinates?(geometry)
      # Coordinates must be an array of numbers
      return false unless geometry["coordinates"].is_a?(Array)

      case geometry["type"]
      when "Point"
        valid_wgs84_coordinates?(geometry["coordinates"])
      when "LineString", "MultiPoint"
        geometry["coordinates"].all? { |coord| valid_wgs84_coordinates?(coord) }
      when "Polygon", "MultiLineString"
        geometry["coordinates"].all? do |ring|
          ring.all? { |coord| valid_wgs84_coordinates?(coord) }
        end
      when "MultiPolygon"
        geometry["coordinates"].all? do |polygon|
          polygon.all? do |ring|
            ring.all? { |coord| valid_wgs84_coordinates?(coord) }
          end
        end
      when "GeometryCollection"
        geometry["geometries"].all? { |geom| valid_coordinates?(geom) }
      else
        false
      end
    end

    def valid_wgs84_coordinates?(coords)
      # Coordinates should be in [longitude, latitude] format
      return false unless coords.is_a?(Array) && coords.size == 2

      longitude, latitude = coords
      # Check if latitude and longitude are valid numbers and within valid ranges
      longitude.is_a?(Numeric) && latitude.is_a?(Numeric) &&
        longitude.between?(-180.0, 180.0) && latitude.between?(-90.0, 90.0)
    end
end
