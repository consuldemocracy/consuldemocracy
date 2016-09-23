class Api::V1::ProposalSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :question, :external_url, :flags_count,
      :cached_votes_up, :comments_count, :created_at, :updated_at, :summary,
      :video_url, :physical_votes, :retired_at, :retired_reason, :retired_explanation,
      :geozone_id
end
