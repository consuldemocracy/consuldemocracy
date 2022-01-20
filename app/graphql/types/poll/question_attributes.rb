module Types
  module Poll
    class QuestionAttributes < Types::BaseInputObject
      argument :title, String, required: true
      argument :question_answers_attributes, [Types::Poll::QuestionAnswerAttributes], required: true
    end
  end
end
