module Mutations
  class CastVoteOnComment < BaseMutation
    argument :comment_id, ID, required: true
    argument :vote, String, required: true, validates: { inclusion: { in: ["up", "down"] }}

    type Types::CommentType

    def resolve(comment_id:, vote:)
      begin
        comment = Comment.find comment_id
        comment.vote_by(voter: context[:current_resource], vote: vote)
        # TODO: What to return here?
        comment
      rescue ActiveRecord::RecordNotFound => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
