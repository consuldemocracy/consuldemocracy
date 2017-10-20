class Polls::QuestionsController < ApplicationController

  load_and_authorize_resource :poll
  load_and_authorize_resource :question, class: "Poll::Question"

  has_orders %w{most_voted newest oldest}, only: :show

  def answer
    answer = @question.answers.find_or_initialize_by(author: current_user)
    answer.answer = params[:answer]
    answer.touch if answer.persisted?

    voter = Poll::Voter.find_or_initialize_by(user: answer.author, poll: answer.poll, origin: "web", token: params[:token])

    if params[:token].present? && answer.valid? && voter.valid?
      answer.save!
      voter.save!

      @question.question_answers.where(question_id: @question).each do |question_answer|
        question_answer.set_most_voted
      end

      @answers_by_question_id = { @question.id => params[:answer] }
    else
      flash.now[:error] = t("poll_questions.show.vote_error")
      render :error
    end
  end

end
