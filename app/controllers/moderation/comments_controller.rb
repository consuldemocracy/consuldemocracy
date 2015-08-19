class Moderation::CommentsController < Moderation::BaseController

  def hide
    @comment = Comment.find(params[:id])
    @comment.hide
  end

end