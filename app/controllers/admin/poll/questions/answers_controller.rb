class Admin::Poll::Questions::AnswersController < Admin::Poll::BaseController
  before_action :load_answer, only: [:show, :edit, :update, :documents]

  load_and_authorize_resource :question, class: "::Poll::Question"

  def new
    @answer = ::Poll::Question::Answer.new
  end

  def create
    @answer = ::Poll::Question::Answer.new(answer_params)

    if @answer.save
      redirect_to admin_question_path(@answer.question),
               notice: t("flash.actions.create.poll_question_answer")
    else
      render :new
    end
  end

  def show
  end

  def edit
  end

  def update
    if @answer.update(answer_params)
      redirect_to admin_question_path(@answer.question),
               notice: t("flash.actions.save_changes.notice")
    else
      redirect_to :back
    end
  end

  def documents
    @documents = @answer.documents

    render 'admin/poll/questions/answers/documents'
  end

  def order_answers
    ::Poll::Question::Answer.order_answers(params[:ordered_list])
    render nothing: true
  end

  private

    def answer_params
      params.require(:poll_question_answer).permit(:title, :description, :question_id, documents_attributes: [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy])
    end

    def load_answer
      @answer = ::Poll::Question::Answer.find(params[:id] || params[:answer_id])
    end

end
