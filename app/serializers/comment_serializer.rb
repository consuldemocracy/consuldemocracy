class CommentSerializer < ActiveModel::Serializer
  attributes :commentable_id, :commentable_type, :body, :subject, :user_id
end
