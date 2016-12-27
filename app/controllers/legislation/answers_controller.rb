class Legislation::AnswersController < Legislation::BaseController
  before_action :authenticate_user!
  before_action :verify_resident!

  load_and_authorize_resource :process
  load_and_authorize_resource :question, through: :process
  load_and_authorize_resource :answer, through: :question

  def create
    @answer.user = current_user
    @answer.save
    redirect_to legislation_process_question_path(@process, @question)
  end

  private
    def answer_params
      params.require(:legislation_answer).permit(
        :legislation_question_option_id,
      )
    end
end
