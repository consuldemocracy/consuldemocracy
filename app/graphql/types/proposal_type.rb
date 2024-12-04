module Types
  class ProposalType < Types::BaseObject
    field :cached_votes_up, Integer, null: true
    collection_field :comments, Types::CommentType, null: true
    field :comments_count, Integer, null: true
    field :confidence_score, Integer, null: true
    field :description, String, null: true
    field :geozone, Types::GeozoneType, null: true
    field :geozone_id, Integer, null: true
    field :hot_score, Integer, null: true
    field :id, ID, null: false
    collection_field :proposal_notifications, Types::ProposalNotificationType, null: true
    field :public_author, Types::UserType, null: true
    field :public_created_at, String, null: true
    field :retired_at, GraphQL::Types::ISO8601DateTime, null: true
    field :retired_explanation, String, null: true
    field :retired_reason, String, null: true
    field :summary, String, null: true
    collection_field :tags, Types::TagType, null: true
    field :title, String, null: true
    field :video_url, String, null: true
    collection_field :votes_for, Types::VoteType, null: true
    collection_field :milestones, Types::MilestoneType, null: true

    def tags
      object.tags.public_for_api
    end

    def geozone
      Geozone.public_for_api.find_by(id: object.geozone)
    end
  end
end
