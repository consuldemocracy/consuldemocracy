class Polls::QuestionsController < ApplicationController
  load_and_authorize_resource :poll
  load_and_authorize_resource :question, class: "Poll::Question"

  has_orders %w[most_voted newest oldest], only: :show

  def answer
    answer = @question.answers.find_or_initialize_by(author: current_user, answer: params[:answer])
    answer.save_and_record_voter_participation(params[:token])

    if !@question.multiple
      @question.answers.where(author: current_user).where.not(answer: params[:answer]).delete_all
    end

    @answers_by_question_id = { @question.id => @question.answers.where(author: current_user).map { |answer| answer.answer } }
  end

  def unanswer
    if @question.multiple
      @question.answers.where(author: current_user, answer: params[:answer]).delete_all
    end

    @answers_by_question_id = { @question.id => @question.answers.where(author: current_user).map { |answer| answer.answer } }
  end
end
