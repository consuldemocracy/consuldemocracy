module Mutations
  class AddReplyToComment < BaseMutation
    argument :comment_id, ID, required: true
    argument :body, String, required: true, validates: { allow_blank: false }

    type Types::CommentType

    def resolve(comment_id:, body:)
      begin
        parent_comment = Comment.find(comment_id)

        Comment.create!({
          body: body,
          commentable_type: parent_comment.commentable_type,
          commentable_id: parent_comment.commentable_id,
          parent_id: comment_id,
          user_id: context[:current_resource].id
        })
      rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
