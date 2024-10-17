module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    collection_field :public_comments, Types::CommentType, null: true
    collection_field :public_debates, Types::DebateType, null: true
    collection_field :public_proposals, Types::ProposalType, null: true
    field :username, String, null: true
  end
end
