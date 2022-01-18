module Mutations
  class AddCommentToDebate < AddComment
    argument :debate_id, ID, required: true

    type Types::CommentType

    def resolve(debate_id:, body:)
      super(commentable_type: "Debate", commentable_id: debate_id, body: body)
    end
  end
end
