class Polls::AnswersController < ApplicationController
  authorize_resource :answer, class: "Poll::Answer"

  before_action :load_page
  before_action :load_question

  def delete
    @question.answers.find_by(author: current_user, answer: params[:answer]).destroy!
    @question.question_answers.each(&:set_most_voted)

    load_answers
    render "polls/questions/answers", format: :js
  end

  private

    def load_page
      @page = params[:page].presence || 1
    end

    def load_question
      @question = Poll::Question.find_by(id: params[:id])
    end

    def load_answers
      @answers = @question.question_answers
      @answers_by_question_id = {
        @question.id => @question.answers.by_author(current_user).order(:order).pluck(:answer)
      }
    end
end
