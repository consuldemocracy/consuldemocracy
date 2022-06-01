module Types
  class CommentType < Types::BaseObject
    field :ancestry, String, null: true
    field :body, String, null: true
    field :cached_votes_down, Integer, null: true
    field :cached_votes_total, Integer, null: true
    field :cached_votes_up, Integer, null: true
    field :commentable_id, Integer, null: true
    field :commentable_type, String, null: true
    field :confidence_score, Integer, null: false
    field :id, ID, null: false
    field :public_author, Types::UserType, null: true
    field :public_created_at, String, null: true
    field :votes_for, Types::VoteType.connection_type, null: true
  end
end
