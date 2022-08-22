module Types
  class VoteType < Types::BaseObject
    field :id, ID, null: false
    field :public_created_at, String, null: true
    field :votable_id, Integer, null: true
    field :votable_type, String, null: true
    field :vote_flag, Boolean, null: true
  end
end
