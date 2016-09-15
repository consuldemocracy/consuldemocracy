class Api::V1::ProposalSerializer < ActiveModel::Serializer
  attributes :id, :title, :description, :question, :external_url, :flags_count,
      :comments_count, :responsible_name, :summary, :video_url, :geozone_id
end
