class MapLocation < ApplicationRecord
  belongs_to :proposal, touch: true
  belongs_to :investment, class_name: "Budget::Investment", touch: true

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

  def self.from_heading(heading)
    new(
      zoom: Budget::Heading::OSM_DISTRICT_LEVEL_ZOOM,
      latitude: (heading.latitude.to_f if heading.latitude.present?),
      longitude: (heading.longitude.to_f if heading.longitude.present?)
    )
  end
end
