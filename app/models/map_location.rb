class MapLocation < ActiveRecord::Base

  belongs_to :proposal, touch: true
  belongs_to :investment, class_name: Budget::Investment, touch: true

  def available?
    latitude.present? && longitude.present? && zoom.present?
  end

end
