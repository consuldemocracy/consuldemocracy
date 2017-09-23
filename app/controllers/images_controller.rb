class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_filter :find_imageable, except: :destroy
  before_filter :prepare_new_image, only: [:new]
  before_filter :prepare_image_for_creation, only: :create

  load_and_authorize_resource

  def new
  end

  def create
    if @image.save
      flash[:notice] = t "images.actions.create.notice"
      redirect_to params[:from]
    else
      flash[:alert] = t "images.actions.create.alert"
      render :new
    end
  end

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

  private

  def image_params
    params.require(:image).permit(:title, :imageable_type, :imageable_id,
                                  :attachment, :cached_attachment, :user_id)
  end

  def find_imageable
    @imageable = params[:imageable_type].constantize.find_or_initialize_by(id: params[:imageable_id])
  end

  def prepare_new_image
    @image = Image.new(imageable: @imageable)
  end

  def prepare_image_for_creation
    @image = Image.new(image_params)
    @image.imageable = @imageable
    @image.user = current_user
  end

end
