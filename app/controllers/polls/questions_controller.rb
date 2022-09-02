class Polls::QuestionsController < ApplicationController
  load_and_authorize_resource :poll
  load_and_authorize_resource :question, class: "Poll::Question"

  has_orders %w[most_voted newest oldest], only: :show

  def answer
    answer = @question.find_or_initialize_user_answer(current_user, params[:answer])
    answer.save_and_record_voter_participation

    respond_to do |format|
      format.html do
        redirect_to request.referer
      end
      format.js do
        render :answers
      end
    end
  end
end
