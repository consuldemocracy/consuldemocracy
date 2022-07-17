class Map < ApplicationRecord
  include Mappable

  belongs_to :budget

  validates :budget_id, presence: true, uniqueness: true

  after_create :set_default_map_location

  def default?
    budget_id == 0
  end

  def set_default_map_location
    if budget_id == 0
      map_location = MapLocation.create!(latitude:  MapLocation.default_latitude,
                                         longitude: MapLocation.default_longitude,
                                         zoom:      MapLocation.default_zoom)
      update!(map_location: map_location)
    end
  end

  def self.default
    find_or_create_by(budget_id: 0)
  end
end
