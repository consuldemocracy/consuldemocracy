class Admin::SiteCustomization::ContentBlocksController < Admin::SiteCustomization::BaseController
  load_and_authorize_resource :content_block, class: "SiteCustomization::ContentBlock"

  def index
    @content_blocks = SiteCustomization::ContentBlock.order(:name, :locale)
  end

  def create
    if @content_block.save
      redirect_to admin_site_customization_content_blocks_path, notice: t('admin.site_customization.content_blocks.create.notice')
    else
      flash.now[:error] = t('admin.site_customization.content_blocks.create.error')
      render :new
    end
  end

  def update
    if @content_block.update(content_block_params)
      redirect_to admin_site_customization_content_blocks_path, notice: t('admin.site_customization.content_blocks.update.notice')
    else
      flash.now[:error] = t('admin.site_customization.content_blocks.update.error')
      render :edit
    end
  end

  def destroy
    @content_block.destroy
    redirect_to admin_site_customization_content_blocks_path, notice: t('admin.site_customization.content_blocks.destroy.notice')
  end

  private

    def content_block_params
      params.require(:site_customization_content_block).permit(
        :name,
        :locale,
        :body
      )
    end
end
