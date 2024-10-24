module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :public_comments, Types::CommentType.connection_type, null: true
    field :public_debates, Types::DebateType.connection_type, null: true
    field :public_proposals, Types::ProposalType.connection_type, null: true
    field :username, String, null: true
  end
end
