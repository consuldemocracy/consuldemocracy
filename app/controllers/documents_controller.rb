class DocumentsController < ApplicationController
  before_action :authenticate_user!
  before_filter :find_documentable, except: [:destroy]
  before_filter :prepare_new_document, only: :new
  before_filter :prepare_document_for_creation, only: :create

  load_and_authorize_resource :except => [:upload]
  skip_authorization_check :only => [:upload]

  def new
  end

  def create
    recover_attachment_from_cache
    if @document.save
      flash[:notice] = t "documents.actions.create.notice"
      redirect_to params[:from]
    else
      flash[:alert] = t "documents.actions.create.alert"
      render :new
    end
  end

  def destroy
    respond_to do |format|
      format.html do
        if @document.destroy
          flash[:notice] = t "documents.actions.destroy.notice"
        else
          flash[:alert] = t "documents.actions.destroy.alert"
        end
        redirect_to params[:from]
      end
      format.js do
        if @document.destroy
          flash.now[:notice] = t "documents.actions.destroy.notice"
        else
          flash.now[:alert] = t "documents.actions.destroy.alert"
        end
      end
    end
  end

  def destroy_upload
    @document = Document.new(attachment: File.open(params[:path]))
    @document.documentable = @documentable

    if @document.attachment.destroy
      flash.now[:notice] = t "documents.actions.destroy.notice"
    else
      flash.now[:alert] = t "documents.actions.destroy.alert"
    end
    render:destroy
  end

  def upload
    @document = Document.new(document_params.merge(user: current_user))
    @document.documentable = @documentable
    if @document.valid?
      @document.attachment.save
      @document.cached_attachment = @document.attachment.path
    else
      @document.attachment.destroy
    end
  end

  private

  def document_params
    params.require(:document).permit(:title, :documentable_type, :documentable_id,
                                     :attachment, :cached_attachment, :user_id)
  end

  def find_documentable
    @documentable = params[:documentable_type].constantize.find_or_initialize_by(id: params[:documentable_id])
  end

  def prepare_new_document
    @document = Document.new(documentable: @documentable, user_id: current_user.id)
  end

  def prepare_document_for_creation
    @document = Document.new(document_params)
    @document.documentable = @documentable
    @document.user = current_user
  end

  def recover_attachment_from_cache
    if @document.attachment.blank? && @document.cached_attachment.present?
      @document.attachment = File.open(@document.cached_attachment)
    end
  end

end
