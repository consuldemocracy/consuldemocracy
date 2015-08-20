class Moderation::UsersController < Moderation::BaseController

  def hide
    user = User.find(params[:id])
    debates_ids = Debate.where(author_id: user.id).pluck(:id)
    comments_ids = Comment.where(user_id: user.id).pluck(:id)

    user.hide
    Debate.hide_all debates_ids
    Comment.hide_all comments_ids

    redirect_to debates_path
  end

end