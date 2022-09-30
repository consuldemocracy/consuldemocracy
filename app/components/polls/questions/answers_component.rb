class Polls::Questions::AnswersComponent < ApplicationComponent
  attr_reader :question
  delegate :can?, :current_user, :user_signed_in?, to: :helpers

  def initialize(question)
    @question = question
  end

  def already_answered?(question_answer)
    user_answer(question_answer).present?
  end

  def question_answers
    question.question_answers
  end

  def user_answer(question_answer)
    user_answers.find_by(answer: question_answer.title)
  end

  private

    def user_answers
      @user_answers ||= question.answers.by_author(current_user)
    end
end
