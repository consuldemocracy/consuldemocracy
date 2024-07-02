module Types
  class InvestmentType < Types::BaseObject
    field :id, ID, null: false
    field :author, Types::UserType, null: true
    field :price, Integer, null: true
    field :feasibility, String, null: true
    field :tsv, String, null: true
    field :title, String, null: true
    field :description, String, null: true
    field :location, String, null: true
    field :comments, Types::CommentType.connection_type, null: true
    field :milestones, Types::MilestoneType.connection_type, null: true
  end
end
