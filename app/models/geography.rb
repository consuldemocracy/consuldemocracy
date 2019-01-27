class Geography < ActiveRecord::Base

  validates :name, presence: true
  validates :color, presence: true
  validates_with GeojsonFormat

  has_many :headings, class_name: Budget::Heading, dependent: :nullify

  def self.active_headings_geographies
    active_headings = {}

    if Budget.current
      Budget.current.headings.each do |active_heading|
        if active_heading.geography
           active_headings[active_heading.geography_id] = active_heading.id
        end
      end
    end

    active_headings
  end

  def parsed_outline_points
    parsed_outline_points = []

    if not outline_points.blank?
      geojson_data_hash = JSON.parse(outline_points)

      coordinates_array = geojson_data_hash["geometry"]["coordinates"]

      if outline_points.match(/"coordinates"\s*:\s*\[{4}/)
        coordinates_array = coordinates_array.reduce([], :concat).reduce([], :concat)
      elsif outline_points.match(/"coordinates"\s*:\s*\[{3}/)
        coordinates_array = coordinates_array.reduce([], :concat)
      end

      coordinates_array.each do |coordinates|
        point_coordinate = []
        point_coordinate << coordinates.second
        point_coordinate << coordinates.first
        parsed_outline_points << point_coordinate
      end
    end

    parsed_outline_points
  end

end

