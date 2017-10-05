class Admin::Poll::Questions::AnswersController < Admin::Poll::BaseController
  before_action :load_question

  load_and_authorize_resource :question, class: "::Poll::Question"

  def new
    @answer = ::Poll::Question::Answer.new
  end

  def create
    @answer = ::Poll::Question::Answer.new(answer_params)

    if @answer.save
      redirect_to admin_question_path(@question),
               notice: t("flash.actions.create.poll_question_answer")
    else
      render :new
    end
  end

  private

    def answer_params
      params.require(:poll_question_answer).permit(:title, :description, :question_id)
    end

    def load_question
      @question = ::Poll::Question.find(params[:question_id])
    end
end
