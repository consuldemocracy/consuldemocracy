class Polls::AnswersController < ApplicationController
  load_and_authorize_resource :question, class: "::Poll::Question"
  load_and_authorize_resource :answer, class: "::Poll::Answer",
                                       through: :question,
                                       through_association: :answers

  def destroy
    @answer.destroy_and_remove_voter_participation

    respond_to do |format|
      format.html do
        redirect_to request.referer
      end
      format.js do
        render "polls/questions/answers"
      end
    end
  end
end
