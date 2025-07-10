class Admin::SiteCustomization::DocumentsController < Admin::SiteCustomization::BaseController
  def index
    @documents = Document.admin.page(params[:page])
  end

  def new
    @document = Document.new
  end

  def create
    @document = initialize_document
    if @document.save
      notice = t("admin.documents.create.success_notice")
      redirect_to admin_site_customization_documents_path, notice: notice
    else
      flash.now[:error] = t("admin.documents.create.unable_notice")
      render :new
    end
  end

  def destroy
    @document = Document.find(params[:id])
    @document.destroy!

    notice = t("admin.documents.destroy.success_notice")
    redirect_to admin_site_customization_documents_path, notice: notice
  end

  private

    def initialize_document
      document = Document.new
      document.attachment = params.dig(:document, :attachment)
      document.title = document.attachment_file_name
      document.user = current_user
      document.admin = true
      document
    end
end
