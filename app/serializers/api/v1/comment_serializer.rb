class Api::V1::CommentSerializer < ActiveModel::Serializer
  attributes :commentable_id, :commentable_type, :body, :subject, :user_id,
      :created_at, :updated_at, :flags_count, :cached_votes_total, :cached_votes_up,
      :cached_votes_down
end
