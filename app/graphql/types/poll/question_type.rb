module Types
  module Poll
    class QuestionType < Types::BaseObject
      field :id, ID, null: false
      field :title, String, null: true
      field :description, String, null: true

      field :question_answers, [Types::Poll::QuestionAnswerType], null: true
      field :answers, [Types::Poll::AnswerType], authenticate: true, null: true

      def answers
        ::Poll::Answer.by_question(object.id).by_author(context[:current_resource]&.id)
      end
    end
  end
end
