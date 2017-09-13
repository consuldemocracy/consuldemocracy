class MapLocation < ActiveRecord::Base

  belongs_to :proposal
  belongs_to :investment, class_name: Budget::Investment

  def available?
    latitude.present? && longitude.present? && zoom.present?
  end

end
