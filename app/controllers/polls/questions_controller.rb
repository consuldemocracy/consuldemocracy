class Polls::QuestionsController < ApplicationController

  load_and_authorize_resource :poll
  load_and_authorize_resource :question, class: 'Poll::Question'

  has_orders %w{most_voted newest oldest}, only: :show

  def answer
    answer = @question.answers.find_or_initialize_by(author: current_user)
    answer.answer = params[:answer]
    answer.touch if answer.persisted?

    voter = Poll::Voter.find_or_initialize_by(user: answer.author, poll: answer.poll, origin: "web", token: params[:token])

    if params[:token].present? && answer.save! && voter.save!
      @answers_by_question_id = { @question.id => params[:answer] }
      log_event("poll", 'vote')

      render :answer
    else
      flash.now[:error] = t("poll_questions.show.vote_error")
      render :error
    end

  end

end
