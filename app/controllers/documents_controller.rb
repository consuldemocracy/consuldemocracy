class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_filter :find_documentable, except: :destroy
  before_filter :prepare_new_document, only: :new
  before_filter :prepare_document_for_creation, only: :create
  load_and_authorize_resource

  def new
  end

  def create
    if @document.save
      flash[:notice] = t "documents.actions.create.notice"
      redirect_to params[:from]
    else
      flash[:alert] = t "documents.actions.create.alert"
      render :new
    end
  end

  def destroy
    if @document.destroy
      flash[:notice] = t "documents.actions.destroy.notice"
    else
      flash[:alert] = t "documents.actions.destroy.alert"
    end
    redirect_to params[:from]
  end

  private

  def find_documentable
    @documentable = params[:documentable_type].constantize.find(params[:documentable_id])
  end

  def prepare_new_document
    @document = Document.new(documentable: @documentable, user_id: @documentable.author_id)
  end

  def prepare_document_for_creation
    @document = Document.new(document_params)
    @document.documentable = @documentable
    @document.user = current_user
  end

  def document_params
    params.require(:document).permit(:title, :documentable_type, :documentable_id, :attachment)
  end

end
