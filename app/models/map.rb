class Map < ApplicationRecord
  include Mappable

  belongs_to :budget

  validates :budget_id, presence: true, uniqueness: true

  def default?
    budget_id == 0
  end

  def self.default
    find_by(budget_id: 0) || create_default!
  end

  def self.create_default!
    map = create!(budget_id: 0)
    map_location = MapLocation.create!(latitude:  MapLocation.default_latitude,
                                       longitude: MapLocation.default_longitude,
                                       zoom:      MapLocation.default_zoom)
    map.update!(map_location: map_location)
    map
  end
end
