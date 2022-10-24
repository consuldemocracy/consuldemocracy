class Admin::Poll::Questions::Answers::DocumentsController < Admin::Poll::BaseController
  include DocumentAttributes

  load_and_authorize_resource :answer, class: "::Poll::Question::Answer"

  def index
  end

  def create
    @answer.attributes = documents_params
    authorize! :update, @answer

    if @answer.save
      redirect_to admin_answer_documents_path(@answer),
        notice: t("admin.documents.create.success_notice")
    else
      render :index
    end
  end

  private

    def documents_params
      params.require(:poll_question_answer).permit(allowed_params)
    end

    def allowed_params
      [documents_attributes: document_attributes]
    end
end
