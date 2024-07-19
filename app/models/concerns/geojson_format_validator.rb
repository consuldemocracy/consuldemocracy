class GeojsonFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present?
      geojson = parse_json(value)
      unless valid_geojson?(geojson)
        record.errors.add(attribute, :invalid)
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

    case geojson['type']
    when 'FeatureCollection'
      valid_feature_collection?(geojson)
    when 'Feature'
      valid_feature?(geojson)
    when 'Point', 'LineString', 'Polygon', 'MultiPoint', 'MultiLineString', 'MultiPolygon', 'GeometryCollection'
      valid_geometry?(geojson)
    else
      false
    end
  end

  def valid_feature_collection?(geojson)
    return false unless geojson['features'].is_a?(Array)

    geojson['features'].all? do |feature|
      valid_feature?(feature)
    end
  end

  def valid_feature?(feature)
    return false unless feature['type'] == 'Feature'
    return false unless feature['geometry'].is_a?(Hash)
    return false unless valid_geometry?(feature['geometry'])
    true
  end

  def valid_geometry?(geometry)
    valid_geometry_types = [
      'Point', 'LineString', 'Polygon',
      'MultiPoint', 'MultiLineString', 'MultiPolygon',
      'GeometryCollection'
    ]

    return false unless valid_geometry_types.include?(geometry['type'])
    return false unless geometry['coordinates'].is_a?(Array)

    # Additional checks can be added for specific geometry types if needed
    true
  end
end
