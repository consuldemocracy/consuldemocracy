module Types
  class TagType < Types::BaseObject
    field :id, ID, null: false
    field :kind, String, null: true
    field :name, String, null: true
    field :taggings_count, Integer, null: true
  end
end
