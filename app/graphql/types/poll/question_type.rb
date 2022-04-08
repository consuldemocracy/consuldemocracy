module Types
  module Poll
    class QuestionType < Types::BaseObject
      field :id, ID, null: false
      field :title, String, null: true

      field :question_answers, [Types::Poll::QuestionAnswerType], null: true
      field :answers_given_by_current_user, [Types::Poll::AnswerType], authenticate: true, null: true

      def answers_given_by_current_user
        ::Poll::Answer.by_question(object.id).by_author(context[:current_resource]&.id)
      end
    end
  end
end
