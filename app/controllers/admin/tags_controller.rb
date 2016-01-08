class Admin::TagsController < Admin::BaseController
  before_action :find_tag, only: [:update, :destroy]

  respond_to :html, :js

  def index
    @tags = ActsAsTaggableOn::Tag.order(kind: :asc, featured: :desc).page(params[:page])
    @tag  = ActsAsTaggableOn::Tag.new
  end

  def create
    @paramTag = params[:tag]
    if @paramTag[:name] == ""
      redirect_to admin_tags_path, notice: t("admin.tags.message")     
    else
      search_tag
      if @tag.present?
        redirect_to admin_tags_path, notice: t("admin.tags.message_find")
      else
        ActsAsTaggableOn::Tag.create(tag_params)
        redirect_to admin_tags_path
      end
    end
  end

  def update
    @tag.update(tag_params)
    redirect_to admin_tags_path
  end

  def destroy
    @tag.destroy
    redirect_to admin_tags_path
  end

  private

    def tag_params
      params.require(:tag).permit(:featured, :name, :kind)
    end

    def find_tag
      @tag = ActsAsTaggableOn::Tag.find(params[:id])
    end
    def search_tag
      @tag = ActsAsTaggableOn::Tag.where("name = '#{@paramTag[:name]}' and
                                                 kind = '#{@paramTag[:kind]}'")
    end
end
