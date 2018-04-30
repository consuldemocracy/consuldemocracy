class MapLocation < ActiveRecord::Base

  belongs_to :proposal, touch: true
  belongs_to :investment, class_name: Budget::Investment, touch: true

  validates :longitude, :latitude, :zoom, presence: true, numericality: true

  def available?
    latitude.present? && longitude.present? && zoom.present?
  end

end

# == Schema Information
#
# Table name: map_locations
#
#  id            :integer          not null, primary key
#  latitude      :float
#  longitude     :float
#  zoom          :integer
#  proposal_id   :integer
#  investment_id :integer
#
