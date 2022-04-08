module Mutations
  class DeleteComment < BaseMutation
    argument :id, ID, required: true

    type Types::CommentType

    def resolve(id:)
      begin
        user = context[:current_resource]
        comment = Comment.find id

        unless comment.author == user
          raise GraphQL::ExecutionError,
            "User '#{user.username}' is not authorized to delete Comment with id '#{comment.id}'"
        end

        comment.delete
        comment
      rescue ActiveRecord::RecordInvalid => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
