module Mutations
  class AddCommentToPoll < AddComment
    argument :poll_id, ID, required: true

    type Types::CommentType

    def resolve(poll_id:, body:)
      super(commentable_type: "Poll", commentable_id: poll_id, body: body)
    end
  end
end
