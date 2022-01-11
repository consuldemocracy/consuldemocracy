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

    field :token, String, null: true, authenticate: true

    def token
      user = context[:current_resource]
      ::Poll::Voter.find_by(poll: object, user: user, origin: "web")&.token || ""
    end

    def questions
      object.questions
        .includes(:question_answers)
        .includes(:answers)
    end
  end
end
