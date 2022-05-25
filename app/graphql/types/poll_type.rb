module Types
  class PollType < Types::BaseObject
    field :id, ID, null: false
    field :published, Boolean, null: true
    field :geozone_restricted, Boolean, null: true
    field :comments_count, Integer, null: true
    field :author_id, Integer, null: true
    field :title, String, null: true

    field :geozone, Types::GeozoneType, null: true
    field :questions, [Types::Poll::QuestionType], null: true
    field :comments, [Types::CommentType], null: true

    # Requires authentication
    field :token, String, null: true

    field :description, String, null: true
    field :summary, String, null: true

    field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :starts_at, GraphQL::Types::ISO8601DateTime, null: true
    field :ends_at, GraphQL::Types::ISO8601DateTime, null: true

    field :results_ready_to_be_shown, Boolean, null: true

    def token
      unless user = context[:current_resource]
        raise GraphQL::ExecutionError, "token requires authentication"
      end

      ::Poll::Voter.find_by(poll: object, user: user, origin: "web")&.token || ""
    end

    def questions
      object.questions
        .includes(:question_answers)
        .includes(:answers)
        .includes(:comments)
    end

    def results_ready_to_be_shown
      user = context[:current_resouce]

      # Same logic as in Abilities::Common and Abilities::Everyone
      (user.present? && poll.related&.author&.id == user.id) ||
        ::Poll.expired.results_enabled.not_budget.ids.include?(object.id)
    end
  end
end
