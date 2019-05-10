class ImagesController < ApplicationController
  before_action :authenticate_user!

  load_and_authorize_resource

  def destroy
    respond_to do |format|
      format.html do
        if @image.destroy
          flash[:notice] = t "images.actions.destroy.notice"
        else
          flash[:alert] = t "images.actions.destroy.alert"
        end
        redirect_to params[:from]
      end
      format.js do
        if @image.destroy
          flash.now[:notice] = t "images.actions.destroy.notice"
        else
          flash.now[:alert] = t "images.actions.destroy.alert"
        end
      end
    end
  end

end
