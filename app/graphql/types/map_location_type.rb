module Types
  class MapLocationType < Types::BaseObject
    field :id, ID, null: true
    field :latitude, Float, null: true
    field :longitude, Float, null: true
    field :zoom, Integer, null: true
  end
end
