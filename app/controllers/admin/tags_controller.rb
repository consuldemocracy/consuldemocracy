class Admin::TagsController < Admin::BaseController
  layout 'admin'

  respond_to :html, :js

  def index
    @tags = ActsAsTaggableOn::Tag.order(featured: :desc)
  end

  def update
    @tag = ActsAsTaggableOn::Tag.find(params[:id])
    @tag.update(tag_params)
    redirect_to admin_tags_path
  end

  private

  def tag_params
    params.require(:tag).permit(:featured)
  end

end
