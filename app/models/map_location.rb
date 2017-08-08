class MapLocation < ActiveRecord::Base

  belongs_to :proposal
  belongs_to :investment

  def filled?
    latitude.present? && longitude.present? && zoom.present?
  end

end
