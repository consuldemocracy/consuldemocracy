module Mutations
  class DeleteComment < BaseMutation
    argument :id, ID, required: true

    type Types::CommentType

    def resolve(id:)
      begin
        user = context[:current_resource]
        comment = Comment.find id

        raise_error_unless_permitted! :destroy, comment

        comment.delete
        comment
      rescue ActiveRecord::RecordInvalid => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
