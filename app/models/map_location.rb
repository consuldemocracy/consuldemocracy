class MapLocation < ActiveRecord::Base

  belongs_to :proposal, touch: true
  belongs_to :investment, class_name: Budget::Investment, touch: true

  validates :longitude, :latitude, :zoom, presence: true, numericality: true

  def available?
    latitude.present? && longitude.present? && zoom.present?
  end

  def json_data
    {
      id: id,
      lat: latitude,
      long: longitude
    }
  end

end
