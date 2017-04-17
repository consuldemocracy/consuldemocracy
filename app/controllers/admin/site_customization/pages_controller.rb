class Admin::SiteCustomization::PagesController < Admin::SiteCustomization::BaseController
  load_and_authorize_resource :page, class: "SiteCustomization::Page"

  def index
    @pages = SiteCustomization::Page.order('slug').page(params[:page])
  end

  def create
    if @page.save
      redirect_to admin_site_customization_pages_path, notice: t('admin.site_customization.pages.create.notice')
    else
      flash.now[:error] = t('admin.site_customization.pages.create.error')
      render :new
    end
  end

  def update
    if @page.update(page_params)
      redirect_to admin_site_customization_pages_path, notice: t('admin.site_customization.pages.update.notice')
    else
      flash.now[:error] = t('admin.site_customization.pages.update.error')
      render :edit
    end
  end

  def destroy
    @page.destroy
    redirect_to admin_site_customization_pages_path, notice: t('admin.site_customization.pages.destroy.notice')
  end

  private

    def page_params
      params.require(:site_customization_page).permit(
        :slug,
        :title,
        :subtitle,
        :content,
        :more_info_flag,
        :print_content_flag,
        :status
      )
    end
end
