class Admin::SiteCustomization::ContentBlocksController < Admin::SiteCustomization::BaseController
  load_and_authorize_resource :content_block, class: "SiteCustomization::ContentBlock",
                               except: [
                                 :delete_heading_content_block,
                                 :edit_heading_content_block,
                                 :update_heading_content_block
                               ]

  def index
    @content_blocks = SiteCustomization::ContentBlock.order(:name, :locale)
    @headings_content_blocks = Budget::ContentBlock.all
    all_settings = Setting.all.group_by(&:type)
    @html_settings = all_settings["html"]
  end

  def create
    if is_heading_content_block?(@content_block.name)
      heading_content_block = new_heading_content_block
      if heading_content_block.save
        notice = t("admin.site_customization.content_blocks.create.notice")
        redirect_to admin_site_customization_content_blocks_path, notice: notice
      else
        flash.now[:error] = t("admin.site_customization.content_blocks.create.error")
        render :new
      end
    elsif @content_block.save
      notice = t("admin.site_customization.content_blocks.create.notice")
      redirect_to admin_site_customization_content_blocks_path, notice: notice
    else
      flash.now[:error] = t("admin.site_customization.content_blocks.create.error")
      render :new
    end
  end

  def edit
    if @content_block.is_a? SiteCustomization::ContentBlock
      @selected_content_block = @content_block.name
    else
      @selected_content_block = "hcb_#{@content_block.heading_id}"
    end
  end

  def update
    if is_heading_content_block?(params[:site_customization_content_block][:name])
      heading_content_block = new_heading_content_block
      if heading_content_block.save
        @content_block.destroy!
        notice = t("admin.site_customization.content_blocks.create.notice")
        redirect_to admin_site_customization_content_blocks_path, notice: notice
      else
        flash.now[:error] = t("admin.site_customization.content_blocks.create.error")
        render :new
      end
    elsif @content_block.update(content_block_params)
      notice = t("admin.site_customization.content_blocks.update.notice")
      redirect_to admin_site_customization_content_blocks_path, notice: notice
    else
      flash.now[:error] = t("admin.site_customization.content_blocks.update.error")
      render :edit
    end
  end

  def destroy
    @content_block.destroy!
    notice = t("admin.site_customization.content_blocks.destroy.notice")
    redirect_to admin_site_customization_content_blocks_path, notice: notice
  end

  def delete_heading_content_block
    Budget::ContentBlock.find(params[:id]).destroy!
    notice = t("admin.site_customization.content_blocks.destroy.notice")
    redirect_to admin_site_customization_content_blocks_path, notice: notice
  end

  def edit_heading_content_block
    @content_block = Budget::ContentBlock.find(params[:id])
    if @content_block.is_a? Budget::ContentBlock
      @selected_content_block = "hcb_#{@content_block.heading_id}"
    else
      @selected_content_block = @content_block.name
    end
    @is_heading_content_block = true
    render :edit
  end

  def update_heading_content_block
    heading_content_block = Budget::ContentBlock.find(params[:id])
    if is_heading_content_block?(params[:name])
      heading_content_block.locale = params[:locale]
      heading_content_block.body = params[:body]
      if heading_content_block.save
        notice = t("admin.site_customization.content_blocks.update.notice")
        redirect_to admin_site_customization_content_blocks_path, notice: notice
      else
        flash.now[:error] = t("admin.site_customization.content_blocks.update.error")
        render :edit
      end
    else
      @content_block = SiteCustomization::ContentBlock.new
      @content_block.name = params[:name]
      @content_block.locale = params[:locale]
      @content_block.body = params[:body]
      if @content_block.save
        heading_content_block.destroy!
        notice = t("admin.site_customization.content_blocks.update.notice")
        redirect_to admin_site_customization_content_blocks_path, notice: notice
      else
        flash.now[:error] = t("admin.site_customization.content_blocks.update.error")
        render :edit
      end
    end
  end

  private

    def content_block_params
      params.require(:site_customization_content_block).permit(allowed_params)
    end

    def allowed_params
      [:name, :locale, :body]
    end

    def is_heading_content_block?(name)
      name.start_with?("hcb_")
    end

    def new_heading_content_block
      heading_content_block = Budget::ContentBlock.new
      heading_content_block.body = params[:site_customization_content_block][:body]
      heading_content_block.locale = params[:site_customization_content_block][:locale]
      block_heading_id = params[:site_customization_content_block][:name].sub("hcb_", "").to_i
      heading_content_block.heading_id = block_heading_id
      heading_content_block
    end
end
