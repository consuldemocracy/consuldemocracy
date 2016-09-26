class Api::V1::CommentSerializer < ActiveModel::Serializer
  attributes :id, :commentable_id, :commentable_type, :body, :subject, :created_at, :updated_at, :flags_count, :cached_votes_total, :cached_votes_up, :cached_votes_down
end
