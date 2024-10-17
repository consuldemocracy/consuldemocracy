module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    connection_field :public_comments, Types::CommentType, null: true
    connection_field :public_debates, Types::DebateType, null: true
    connection_field :public_proposals, Types::ProposalType, null: true
    field :username, String, null: true
  end
end
