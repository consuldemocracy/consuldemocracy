class GeojsonFormat < ActiveModel::Validator
  def validate(record)
    if record.documents.any?
      geojson_document = record.documents.first
      geojson_file_path = (not geojson_document.cached_attachment.blank?) ? geojson_document.cached_attachment : Rails.root.join("public" + geojson_document.attachment.url)

      if File.exist?(geojson_file_path)
        geoson_file = File.read(geojson_file_path)
        data_hash = JSON.parse (geoson_file)

        if (not data_hash.key?("geometry") or not data_hash["geometry"].key?("coordinates"))
          record.errors.add(:base, "The file content does not follow the GeoJSON file format.")
        else
          record.outline_points = parse_geojson_file(data_hash)
        end
      end
    end
  end

  private

  def parse_geojson_file(data_hash)
    outline_points = []

    data_hash["geometry"]["coordinates"].each do |coordinates|
      point_coordinate = [] 
      point_coordinate << coordinates.second
      point_coordinate << coordinates.first
      outline_points << point_coordinate
    end

    outline_points
  end

end
