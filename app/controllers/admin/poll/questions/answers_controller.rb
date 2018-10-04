class Admin::Poll::Questions::AnswersController < Admin::Poll::BaseController
  include Translatable

  before_action :load_answer, only: [:show, :edit, :update, :documents]

  def new
    @answer = ::Poll::Question::Answer.new
    @question = ::Poll::Question.find(params[:question_id])
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
      documents_attributes = [:id, :title, :attachment, :cached_attachment, :user_id, :_destroy]
      attributes = [:title, :description, :question_id, documents_attributes: documents_attributes]
      params.require(:poll_question_answer).permit(*attributes, *translation_params(Poll::Question::Answer))
    end

    def load_answer
      @answer = ::Poll::Question::Answer.find(params[:id] || params[:answer_id])
    end

    def resource
      load_answer unless @answer
      @answer
    end
end
