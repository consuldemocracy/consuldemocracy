class Admin::Poll::Questions::AnswersController < Admin::Poll::BaseController
  include Translatable
  include DocumentAttributes

  load_and_authorize_resource :question, class: "::Poll::Question"
  load_and_authorize_resource class: "::Poll::Question::Answer",
                              through: :question,
                              through_association: :question_answers,
                              except: :documents

  def new
  end

  def create
    if @answer.save
      redirect_to admin_question_path(@question),
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
      redirect_to admin_question_path(@question),
               notice: t("flash.actions.save_changes.notice")
    else
      render :edit
    end
  end

  def documents
    @answer = ::Poll::Question::Answer.find(params[:answer_id])
    @documents = @answer.documents

    render "admin/poll/questions/answers/documents"
  end

  def order_answers
    ::Poll::Question::Answer.order_answers(params[:ordered_list])
    head :ok
  end

  private

    def answer_params
      params.require(:poll_question_answer).permit(allowed_params)
    end

    def allowed_params
      attributes = [:title, :description, :given_order, documents_attributes: document_attributes]

      [*attributes, translation_params(Poll::Question::Answer)]
    end

    def resource
      load_answer unless @answer
      @answer
    end
end
