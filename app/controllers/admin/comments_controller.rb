class Admin::CommentsController < Admin::BaseController

  def index
    @comments = Comment.only_hidden
  end

  def restore
    @comment = Comment.with_hidden.find(params[:id])
    @comment.restore
    redirect_to admin_comments_path, notice: t('admin.comments.restore.success')
  end

end