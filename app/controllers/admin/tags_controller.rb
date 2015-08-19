class Admin::TagsController < Admin::BaseController
  before_action :find_tag, only: [:update, :destroy]

  respond_to :html, :js

  def index
    @tags = ActsAsTaggableOn::Tag.order(featured: :desc).page(params[:page])
    @tag  = ActsAsTaggableOn::Tag.new
  end

  def create
    ActsAsTaggableOn::Tag.create(tag_params)
    redirect_to admin_tags_path
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
      params.require(:tag).permit(:featured, :name)
    end

    def find_tag
      @tag = ActsAsTaggableOn::Tag.find(params[:id])
    end

end
