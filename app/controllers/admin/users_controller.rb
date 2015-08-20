class Admin::UsersController < Admin::BaseController

  def index
    @users = User.only_hidden.page(params[:page])
  end

  def show
    @user = User.with_hidden.find(params[:id])
    @debates = Debate.where(author_id: @user.id).with_hidden.page(params[:page])
    @comments = Comment.where(user_id: @user.id).with_hidden.page(params[:page])
  end

  def restore
    user = User.with_hidden.find(params[:id])
    if hidden_at = user.hidden_at
      debates_ids = Debate.only_hidden.where(author_id: user.id).where("debates.hidden_at > ?", hidden_at).pluck(:id)
      comments_ids = Comment.only_hidden.where(user_id: user.id).where("comments.hidden_at > ?", hidden_at).pluck(:id)

      user.restore
      Debate.restore_all debates_ids
      Comment.restore_all comments_ids
    end
    redirect_to admin_users_path, notice: t('admin.users.restore.success')
  end
end