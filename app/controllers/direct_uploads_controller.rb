class DirectUploadsController < ApplicationController

  def destroy_upload
    @document = Document.new(cached_attachment: params[:path])
    @document.set_attachment_from_cached_attachment
    @document.cached_attachment = nil
    @document.documentable = @documentable

    if @document.attachment.destroy
      flash.now[:notice] = t "documents.actions.destroy.notice"
    else
      flash.now[:alert] = t "documents.actions.destroy.alert"
    end
    render :destroy
  end

  def upload
    @document = Document.new(document_params.merge(user: current_user))
    @document.documentable = @documentable
    @document.valid?

    if @document.valid?
      @document.attachment.save
      @document.set_cached_attachment_from_attachment(URI(request.url))
    else
      @document.attachment.destroy
    end
  end

  private

  def set_attachment_container_resource
    @container_resource = params[:resource_type]
  end

  def find_attachment_container_resource
    @uplo = params[:documentable_type].constantize.find_or_initialize_by(id: params[:documentable_id])
  end

end