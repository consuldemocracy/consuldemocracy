class Admin::TagsController < Admin::BaseController
  before_action :find_tag, only: [:update, :destroy]
  before_action :tags, only: [:index, :create]

  respond_to :html, :js

  def index
    @tag = Tag.category.new
  end

  def create
    @tag = Tag.find_or_initialize_by(tag_params)

    save_and_update = @tag.save && @tag.update!(kind: "category")

    if save_and_update
      redirect_to admin_tags_path
    else
      render :index
    end
  end

  def destroy
    @tag.destroy!
    redirect_to admin_tags_path
  end

  private

    def tags
      @tags ||= Tag.category.page(params[:page])
    end

    def tag_params
      params.require(:tag).permit(:name)
    end

    def find_tag
      @tag = Tag.category.find(params[:id])
    end
end
