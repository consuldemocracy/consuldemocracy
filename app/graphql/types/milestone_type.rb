module Types
  class MilestoneType < Types::BaseObject
    field :title, String, null: true
    field :description, String, null: true
    field :id, ID, null: false
    field :publication_date, GraphQL::Types::ISO8601Date, null: true
  end
end
