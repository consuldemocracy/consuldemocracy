class Moderation::UsersController < Moderation::BaseController
  before_action :load_users, only: :index

  load_and_authorize_resource

  def index
  end

  def hide_in_moderation_screen
    block_user
    flash[:notice] = I18n.t("moderation.users.notice_hide")
    redirect_to admin_users_path
  end

  def hide
    block_user

    redirect_to debates_path
  end

  def show_in_moderation_screen
    unblock_user

    redirect_with_query_params_to({ action: :index }, { notice: I18n.t("moderation.users.notice_show") })
  end

  private

    def load_users
      @users = User.with_hidden.search(params[:search]).page(params[:page]).for_render
    end

    def block_user
      @user.block
      Activity.log(current_user, :block, @user)
    end

    def unblock_user
      @user.show_user
      Activity.log(current_user, :show, @user)
    end
end
