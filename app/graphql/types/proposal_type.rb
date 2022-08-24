module Types
  class ProposalType < Types::BaseObject
    IMAGE_SIZES = [:small, :medium, :large, :thumb].freeze

    field :cached_votes_up, Integer, null: true
    field :comments, Types::CommentType.connection_type, null: true
    field :comments_count, Integer, null: true
    field :confidence_score, Integer, null: true
    field :description, String, null: true
    field :documents, [Types::DocumentType], null: true
    field :geozone, Types::GeozoneType, null: true
    field :geozone_id, Integer, null: true
    field :hot_score, Integer, null: true
    field :id, ID, null: false
    field :image, Types::ImageType, null: true
    field :map_location, Types::MapLocationType, null: true
    field :proposal_notifications, Types::ProposalNotificationType.connection_type, null: true
    field :public_author, Types::UserType, null: true
    field :public_created_at, String, null: true
    field :published, Boolean, null: true
    field :retired_at, GraphQL::Types::ISO8601DateTime, null: true
    field :retired_explanation, String, null: true
    field :retired_reason, String, null: true
    field :summary, String, null: true
    field :tags, Types::TagType.connection_type, null: true
    field :title, String, null: true
    field :video_url, String, null: true
    field :votes_for, Types::VoteType.connection_type, null: true

    # Requires authentication
    field :current_user_has_voted, Boolean, null: true

    def tags
      object.tags.public_for_api
    end

    def geozone
      Geozone.public_for_api.find_by(id: object.geozone)
    end

    def published
      object.published?
    end

    def current_user_has_voted
      unless context[:current_resource]
        raise GraphQL::ExecutionError, "currentUserHasVoted requires authentication"
      end

      context[:current_resource].votes.find_by(votable_type: "Proposal", votable_id: object.id).present?
    end
  end
end
