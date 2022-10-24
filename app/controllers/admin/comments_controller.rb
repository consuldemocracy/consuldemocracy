class Admin::CommentsController < Admin::BaseController
  def index
    @comments = Comment.sort_by_newest.page(params[:page])
  end
end
