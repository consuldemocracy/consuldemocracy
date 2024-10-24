class Admin::Poll::Questions::Options::DocumentsController < Admin::Poll::BaseController
  include DocumentAttributes

  load_and_authorize_resource :option, class: "::Poll::Question::Option"

  def index
  end

  def create
    @option.attributes = documents_params
    authorize! :update, @option

    if @option.save
      redirect_to admin_option_documents_path(@option),
                  notice: t("admin.documents.create.success_notice")
    else
      render :index
    end
  end

  private

    def documents_params
      params.require(:poll_question_option).permit(allowed_params)
    end

    def allowed_params
      [documents_attributes: document_attributes]
    end
end
