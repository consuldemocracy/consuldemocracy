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
      notice = t("admin.site_customization.images.update.notice")
      redirect_to admin_site_customization_images_path, notice: notice
    else
      flash.now[:error] = t("admin.site_customization.images.update.error")

      @images = SiteCustomization::Image.all_images
      idx = @images.index { |e| e.name == @image.name }
      @images[idx] = @image

      render :index
    end
  end

  def destroy
    if @image.update(image: nil)
      notice = t("admin.site_customization.images.destroy.notice")
    else
      notice = t("admin.site_customization.images.destroy.error")
    end

    redirect_to admin_site_customization_images_path, notice: notice
  end

  private

    def image_params
      params.require(:site_customization_image).permit(allowed_params)
    end

    def allowed_params
      [:image]
    end
end
