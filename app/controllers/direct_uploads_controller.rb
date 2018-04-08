class DirectUploadsController < ApplicationController
  include DirectUploadsHelper
  include ActionView::Helpers::UrlHelper
  before_action :authenticate_user!

  load_and_authorize_resource except: :create
  skip_authorization_check only: :create

  helper_method :render_destroy_upload_link

  def create
    @direct_upload = DirectUpload.new(direct_upload_params.merge(user: current_user, attachment: params[:attachment]))

    if @direct_upload.valid?
      @direct_upload.save_attachment
      @direct_upload.relation.set_cached_attachment_from_attachment

      render json: { cached_attachment: @direct_upload.relation.cached_attachment,
                     filename: @direct_upload.relation.attachment.original_filename,
                     destroy_link: render_destroy_upload_link(@direct_upload).html_safe,
                     attachment_url: @direct_upload.relation.attachment.url}
    else
      @direct_upload.destroy_attachment
      render json: { errors: @direct_upload.errors[:attachment].join(", ") },
             status: 422
    end
  end

  def destroy
    @direct_upload = DirectUpload.new(direct_upload_params.merge(user: current_user))
    @direct_upload.relation.set_attachment_from_cached_attachment

    if @direct_upload.destroy_attachment
      render json: :ok
    else
      render json: :error
    end
  end

  private

  def direct_upload_params
    params.require(:direct_upload)
          .permit(:resource, :resource_type, :resource_id, :resource_relation,
                  :attachment, :cached_attachment, attachment_attributes: [])
  end

end