class Polls::Questions::AnswersComponent < ApplicationComponent
  attr_reader :question
  delegate :can?, :current_user, :user_signed_in?, to: :helpers

  def initialize(question)
    @question = question
  end

  def answers_by_question_id
    if params[:answer]
      { question.id => params[:answer] }
    else
      stored_answers_by_question_id
    end
  end

  def voted_before_sign_in?
    question.answers.where(author: current_user).any? do |vote|
      vote.updated_at < current_user.current_sign_in_at
    end
  end

  private

    def stored_answers_by_question_id
      poll_answers = ::Poll::Answer.by_question(question.poll.question_ids).by_author(current_user&.id)
      poll_answers.each_with_object({}) do |answer, answers_by_question_id|
        answers_by_question_id[answer.question_id] = answer.answer
      end
    end
end
