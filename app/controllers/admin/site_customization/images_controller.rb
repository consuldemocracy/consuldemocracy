class Admin::SiteCustomization::ImagesController < Admin::SiteCustomization::BaseController
  load_and_authorize_resource :image, class: "SiteCustomization::Image"

  def index
    @images = SiteCustomization::Image.all_images
  end

  def update
    if params[:site_customization_image].nil?
      redirect_to admin_site_customization_images_path
      return
    end

    if @image.update(image_params)
      redirect_to admin_site_customization_images_path, notice: t('admin.site_customization.images.update.notice')
    else
      flash.now[:error] = t('admin.site_customization.images.update.error')

      @images = SiteCustomization::Image.all_images
      idx = @images.index {|e| e.name == @image.name }
      @images[idx] = @image

      render :index
    end
  end

  def destroy
    @image.image = nil
    if @image.save
      redirect_to admin_site_customization_images_path, notice: t('admin.site_customization.images.destroy.notice')
    else
      redirect_to admin_site_customization_images_path, notice: t('admin.site_customization.images.destroy.error')
    end
  end

  private

    def image_params
      params.require(:site_customization_image).permit(
        :image
      )
    end
end
