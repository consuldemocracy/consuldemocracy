class Geozone < ApplicationRecord
  include Graphqlable

  has_many :proposals
  has_many :debates
  has_many :users
  has_many :postcodes
  has_many :headings, class_name: "Budget::Heading", dependent: :nullify
  validates :name, presence: true
  validates :geojson, geojson_format: true

  scope :public_for_api, -> { all }

  def self.names
    Geozone.pluck(:name)
  end

  def safe_to_destroy?
    Geozone.reflect_on_all_associations(:has_many).all? do |association|
      association.klass.where(geozone: self).empty?
    end
  end

  def outline_points
    normalize(geojson)
  end

  def coordinates
    JSON.parse(geojson)["geometry"]["coordinates"] if geojson.present?
  end

  private

    def normalize(geojson)
      if geojson.present?
        parsed_geojson = JSON.parse(geojson)

        # Handle FeatureCollection
        if parsed_geojson["type"] == "FeatureCollection"
          parsed_geojson["features"].each do |feature|
            feature["properties"] ||= {}
          end
          parsed_geojson.to_json

        # Handle Feature
        elsif parsed_geojson["type"] == "Feature"
          parsed_geojson["properties"] ||= {}
          wrap_in_feature_collection(parsed_geojson)

        # Handle Geometry alone
        elsif parsed_geojson["geometry"]
          parsed_geojson["properties"] ||= {}
          wrap_in_feature_collection(wrap_in_feature(parsed_geojson["geometry"]))

        # Handle raw geometry (coordinates) which should be a Feature
        elsif parsed_geojson["type"] && parsed_geojson["coordinates"]
          wrap_in_feature_collection(wrap_in_feature(parsed_geojson))

        # Handle a valid geometry with type and coordinates
        elsif parsed_geojson["geometry"] &&
              parsed_geojson["geometry"]["type"] &&
              parsed_geojson["geometry"]["coordinates"]
          wrapped_feature = wrap_in_feature(parsed_geojson["geometry"])
          wrapped_feature["properties"] ||= {}
          wrap_in_feature_collection(wrapped_feature)

        else
          raise ArgumentError, "Invalid GeoJSON fragment"
        end
      end
    end

    def wrap_in_feature(geometry)
      {
        type: "Feature",
        geometry: geometry,
        properties: {}
      }
    end

    def wrap_in_feature_collection(feature)
      {
        type: "FeatureCollection",
        features: [feature]
      }.to_json
    end
end
