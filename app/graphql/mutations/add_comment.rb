module Mutations
  class AddComment < BaseMutation
    argument :body, String, required: true, validates: { allow_blank: false }

    type Types::CommentType

    def resolve(commentable_id:, commentable_type:, body:)
      begin
        Comment.create!({
          body: body,
          commentable_type: commentable_type,
          commentable_id: commentable_id,
          user_id: context[:current_resource].id
        })
      rescue ActiveRecord::RecordInvalid => e
        raise GraphQL::ExecutionError, e.message
      end

      # TODO: Do we want notifications like in CommentsController?
      # notifiable = comment.reply? ? comment.parent : comment.commentable
      # notifiable_author_id = notifiable&.author_id
      # if notifiable_author_id.present? && notifiable_author_id != comment.author_id
      #   Notification.add(notifiable.author, notifiable)
      # end
    end
  end
end
