class Api::V1::Proposals::ShowSerializer < Api::V1::ProposalSerializer
  # hardcoded url until comments are available as a resource for the api
  # link(:comments) { api_comments_path(commentable_id: object.id)}
  link(:comments) { "api/comments?commentable_id=#{object.id}" }
end
