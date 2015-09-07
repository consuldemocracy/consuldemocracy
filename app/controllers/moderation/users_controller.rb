class Moderation::UsersController < Moderation::BaseController

  def index
    @users = User.with_hidden.search(params[:name_or_email]).page(params[:page]).for_render
  end

  def hide_in_moderation_screen
    hide_user
    redirect_to request.query_parameters.merge(action: :index), notice: I18n.t('moderation.users.notice_hide')
  end

  def hide
    hide_user
    redirect_to debates_path
  end

  private
    def hide_user
      user = User.find(params[:id])
      debates_ids = Debate.where(author_id: user.id).pluck(:id)
      comments_ids = Comment.where(user_id: user.id).pluck(:id)

      user.hide
      Debate.hide_all debates_ids
      Comment.hide_all comments_ids
    end

end