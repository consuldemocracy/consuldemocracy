class MapLocation < ApplicationRecord
  belongs_to :proposal, touch: true
  belongs_to :investment, class_name: "Budget::Investment", touch: true
  belongs_to :map

  validates :longitude, :latitude, :zoom, presence: true, numericality: true

  def available?
    latitude.present? && longitude.present? && zoom.present?
  end

  def json_data
    {
      investment_id: investment_id,
      proposal_id: proposal_id,
      lat: latitude,
      long: longitude
    }
  end

  def from_map(map)
    self.latitude = map.map_location.latitude
    self.longitude = map.map_location.longitude
    self.zoom = map.map_location.zoom
    self
  end

  def self.default_latitude
    51.48
  end

  def self.default_longitude
    0.0
  end

  def self.default_zoom
    10
  end

  def self.load_from_heading(heading)
    map = new
    map.zoom = Budget::Heading::OSM_DISTRICT_LEVEL_ZOOM
    map.latitude = heading.latitude.to_f if heading.latitude.present?
    map.longitude = heading.longitude.to_f if heading.longitude.present?
    map
  end
end
