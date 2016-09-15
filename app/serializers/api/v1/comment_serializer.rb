class Api::V1::CommentSerializer < ActiveModel::Serializer
  attributes :commentable_id, :commentable_type, :body, :subject, :user_id
end
