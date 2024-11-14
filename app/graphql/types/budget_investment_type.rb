module Types
  class BudgetInvestmentType < Types::BaseObject
    field :id, ID, null: false
    field :public_author, Types::UserType, null: true
    field :price, GraphQL::Types::BigInt, null: true
    field :feasibility, String, null: true
    field :title, String, null: true
    field :description, String, null: true
    field :location, String, null: true
    collection_field :comments, Types::CommentType, null: true
    field :comments_count, Integer, null: true
    collection_field :milestones, Types::MilestoneType, null: true
  end
end
