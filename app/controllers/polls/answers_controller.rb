class Polls::AnswersController < ApplicationController
  load_and_authorize_resource :question, class: "::Poll::Question"
  load_and_authorize_resource :answer, class: "::Poll::Answer",
                                       through: :question,
                                       through_association: :answers,
                                       only: :destroy

  def create
    authorize! :answer, @question

    answer = @question.find_or_initialize_user_answer(current_user, params[:option_id])
    answer.save_and_record_voter_participation

    respond_to do |format|
      format.html do
        redirect_to request.referer
      end
      format.js do
        render :show
      end
    end
  end

  def destroy
    @answer.destroy_and_remove_voter_participation

    respond_to do |format|
      format.html do
        redirect_to request.referer
      end
      format.js do
        render :show
      end
    end
  end
end
