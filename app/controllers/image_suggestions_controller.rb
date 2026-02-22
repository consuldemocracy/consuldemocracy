class ImageSuggestionsController < ApplicationController
  include DirectUploadsHelper
  include ActionView::Helpers::UrlHelper

  before_action :authenticate_user!
  skip_authorization_check

  def create
    @resource_type = params[:resource_type]
    @title = image_suggestion_params[:title]
    @description = image_suggestion_params[:description]

    respond_to do |format|
      format.js
    end
  end

  def attach
    begin
      attachment = ImageSuggestions::Pexels.download(params[:id])
    rescue ImageSuggestions::Pexels::PexelsError, Pexels::APIError => e
      return render json: { errors: e.message }, status: :unprocessable_entity
    end

    @direct_upload = DirectUpload.new(
      resource_type: params[:resource_type],
      resource_id: params[:resource_id],
      resource_relation: "image",
      attachment: attachment,
      user: current_user
    )

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

    def image_suggestion_params
      @image_suggestion_params ||= params.require(@resource_type.parameterize.underscore)
                                         .permit(translations_attributes: [:title, :description])
                                         .fetch(:translations_attributes, {})
                                         .values&.first || {}
    end
end
