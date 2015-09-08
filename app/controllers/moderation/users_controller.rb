class Moderation::UsersController < Moderation::BaseController

  before_filter :load_users, only: :index

  load_and_authorize_resource

  def index
  end

  def hide_in_moderation_screen
    @user.block
    redirect_to request.query_parameters.merge(action: :index), notice: I18n.t('moderation.users.notice_hide')
  end

  def hide
    @user.block
    redirect_to debates_path
  end

  private

  def load_users
    @users = User.with_hidden.search(params[:name_or_email]).page(params[:page]).for_render
  end

end
