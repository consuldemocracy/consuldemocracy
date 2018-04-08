class Polls::QuestionsController < ApplicationController

  load_and_authorize_resource :poll
  load_and_authorize_resource :question, class: 'Poll::Question'

  has_orders %w{most_voted newest oldest}, only: :show

  def answer
    answer = @question.answers.find_or_initialize_by(author: current_user)
    token = params[:token]

    answer.answer = params[:answer]
    answer.touch if answer.persisted?
    answer.save!
    answer.record_voter_participation(token)
    @question.question_answers.where(question_id: @question).each do |question_answer|
      question_answer.set_most_voted
    end

    @answers_by_question_id = { @question.id => params[:answer] }
  end

end
