class ImagesController < ApplicationController
  before_action :authenticate_user!
  before_filter :find_imageable, except: :destroy
  before_filter :prepare_new_image, only: [:new, :new_nested]
  before_filter :prepare_image_for_creation, only: :create
  before_filter :find_image, only: :destroy

  load_and_authorize_resource except: :upload
  skip_authorization_check only: :upload

  def new
  end

  def new_nested
  end

  def create
    recover_attachments_from_cache

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

  def destroy_upload
    @image = Image.new(cached_attachment: params[:path])
    @image.set_attachment_from_cached_attachment
    @image.cached_attachment = nil
    @image.imageable = @imageable

    if @image.attachment.destroy
      flash.now[:notice] = t "images.actions.destroy.notice"
    else
      flash.now[:alert] = t "images.actions.destroy.alert"
    end
    render :destroy
  end

  def upload
    @image = Image.new(image_params.merge(user: current_user))
    @image.imageable = @imageable

    if @image.valid?
      @image.attachment.save
      @image.set_cached_attachment_from_attachment(URI(request.url))
    else
      @image.attachment.destroy
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

  def find_image
    @image = Image.find(params[:id])
  end

  def prepare_new_image
    @image = Image.new(imageable: @imageable)
  end

  def prepare_image_for_creation
    @image = Image.new(image_params)
    @image.imageable = @imageable
    @image.user = current_user
  end

  def recover_attachments_from_cache
    if @image.attachment.blank? && @image.cached_attachment.present?
      @image.set_attachment_from_cached_attachment
    end
  end

end
