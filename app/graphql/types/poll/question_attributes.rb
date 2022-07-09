module Types
  module Poll
    class QuestionAttributes < GraphQL::Schema::InputObject
      argument :title, String, required: true
      argument :question_answers_attributes, [Types::Poll::QuestionAnswerAttributes], required: true
    end
  end
end
