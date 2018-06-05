class TinymceAssetsController < ApplicationController
  authorize_resource

  respond_to :json

  def create
    geometry = Paperclip::Geometry.from_file params[:file]
    image    = TinymceAsset.create params_permit

    render json: {
      image: {
        url:    image.file.url,
        height: geometry.height.to_i,
        width:  geometry.width.to_i
      }
    }, layout: false, content_type: "text/html"
  end

  private

    def params_permit
      params.permit(:file)
    end

end