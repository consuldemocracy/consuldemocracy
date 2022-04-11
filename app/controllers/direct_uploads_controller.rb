class DirectUploadsController < ApplicationController
  include DirectUploadsHelper
  include ActionView::Helpers::UrlHelper
  before_action :authenticate_user!

  skip_authorization_check only: :create

  helper_method :render_destroy_upload_link

  def create
    @direct_upload = DirectUpload.new(direct_upload_params.merge(user: current_user, attachment: params[:attachment]))

    if @direct_upload.valid?
      @direct_upload.save_attachment
      @direct_upload.relation.set_cached_attachment_from_attachment

      render json: { cached_attachment: @direct_upload.relation.cached_attachment,
                     filename: @direct_upload.relation.attachment_file_name,
                     destroy_link: render_destroy_upload_link(@direct_upload),
                     attachment_url: polymorphic_path(@direct_upload.relation.attachment) }
    else
      render json: { errors: @direct_upload.errors[:attachment].join(", ") },
             status: :unprocessable_entity
    end
  end

  private

    def direct_upload_params
      params.require(:direct_upload)
            .permit(allowed_params)
    end

    def allowed_params
      [
        :resource, :resource_type, :resource_id, :resource_relation,
        :attachment, :cached_attachment, attachment_attributes: []
      ]
    end
end
