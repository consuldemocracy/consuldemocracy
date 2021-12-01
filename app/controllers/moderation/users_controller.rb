class Moderation::UsersController < Moderation::BaseController
  before_action :load_users, only: :index

  load_and_authorize_resource

  def index
  end

  def hide
    block_user

    redirect_with_query_params_to index_path_options, { notice: I18n.t("moderation.users.notice_hide") }
  end

  private

    def load_users
      @users = User.with_hidden.search(params[:search]).page(params[:page]).for_render
    end

    def block_user
      @user.block
      Activity.log(current_user, :block, @user)
    end

    def index_path_options
      if request.referer
        referer_params = Rails.application.routes.recognize_path(request.referer)

        referer_params.except(:id).merge({
          controller: "/#{referer_params[:controller]}",
          action: :index
        })
      else
        { action: :index }
      end
    end
end
