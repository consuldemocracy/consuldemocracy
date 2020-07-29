class Admin::TagsController < Admin::BaseController
  before_action :find_tag, only: [:update, :destroy]

  respond_to :html, :js

  def index
    @tags = Tag.category.page(params[:page])
    @tag  = Tag.category.new
  end

  def create
    Tag.find_or_create_by!(name: tag_params["name"]).update!(kind: "category")

    redirect_to admin_tags_path
  end

  def destroy
    @tag.destroy!
    redirect_to admin_tags_path
  end

  private

    def tag_params
      params.require(:tag).permit(:name)
    end

    def find_tag
      @tag = Tag.category.find(params[:id])
    end
end
