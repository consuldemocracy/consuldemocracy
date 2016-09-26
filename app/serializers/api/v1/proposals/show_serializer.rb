class Api::V1::Proposals::ShowSerializer < Api::V1::ProposalSerializer
  has_many :comments, serializer: Api::V1::CommentSerializer do
    link(:related) { api_comments_path(commentable_id: object.id, commentable_type: "Proposal") }
  end
end
