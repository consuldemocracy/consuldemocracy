module Mutations
  class ProvideAnswerToPollQuestion < BaseMutation
    argument :poll_question_id, String, required: true
    argument :token, String, required: true
    argument :answer, String, required: true

    type Types::Poll::AnswerType

    def resolve(poll_question_id:, token:, answer:)
      begin
        @question = Poll::Question.find(poll_question_id)
        poll_answer = @question.answers.find_or_initialize_by(author: context[:current_resource])
        token = token

        poll_answer.answer = answer
        poll_answer.save_and_record_voter_participation(token)
      rescue ActiveRecord::RecordInvalid => e
        raise GraphQL::ExecutionError, e.message
      end
    end
  end
end
