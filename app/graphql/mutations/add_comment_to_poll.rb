module Mutations
  class AddCommentToPoll < BaseMutation
    argument :poll_id, ID, required: true
    argument :body, String, required: true, validates: { allow_blank: false }
    argument :parent_id, ID, required: false

    type Types::CommentType

    def resolve(poll_id:, body:, parent_id: nil)
      begin
        Comment.create!({
          body: body,
          commentable_type: "Poll",
          commentable_id: poll_id,
          parent_id: parent_id,
          user_id: context[:current_resource].id
        })
      rescue ActiveRecord::RecordInvalid => e
        raise GraphQL::ExecutionError, "#{e.message}"
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
