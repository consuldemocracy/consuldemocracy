class MapLocation < ActiveRecord::Base

  belongs_to :proposal
  belongs_to :investment

  def available?
    latitude.present? && longitude.present? && zoom.present?
  end

end
