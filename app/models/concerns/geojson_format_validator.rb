class GeojsonFormatValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present?
      geojson = parse_json(value)

      unless geojson?(geojson)
        record.errors.add(attribute, :invalid)
      end
    end
  end

  private

    def parse_json(geojson_data)
      JSON.parse(geojson_data) rescue nil
    end

    def geojson?(geojson)
      return false unless geojson.is_a?(Hash)

      geojson.dig("geometry", "coordinates").is_a?(Array)
    end
end
