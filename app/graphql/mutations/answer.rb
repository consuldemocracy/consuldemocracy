# Scenario: User answers question of a poll
module Mutations
  class Answer < BaseMutation

    # The id of the Poll::Question
    argument :id, String, required: true
    argument :token, String, required: true
    argument :answer, String, required: true

    type Types::Poll::AnswerType

    def resolve(id:, token:, answer:)
      @question = Poll::Question.find id
      poll_answer = @question.answers.find_or_initialize_by(author: context[:current_resource])
      token = token

      poll_answer.answer = answer
      poll_answer.save_and_record_voter_participation(token)
    end

  end
end
