class Moderation::UsersController < Moderation::BaseController
  before_action :load_users, only: :index

  load_and_authorize_resource

  def index
  end

  def hide
    hide_user

    redirect_with_query_params_to({ action: :index }, { notice: I18n.t("moderation.users.notice_hide") })
  end

  def block
    block_user

    redirect_with_query_params_to index_path_options, { notice: I18n.t("moderation.users.notice_block") }
  end

  private

    def load_users
      @users = User.with_hidden.search(params[:search]).page(params[:page]).for_render
    end

    def hide_user
      @user.hide
      Activity.log(current_user, :hide, @user)
    end

    def block_user
      @user.block
      Activity.log(current_user, :block, @user)
    end

    def index_path_options
      if request.referer
        referer_params = Rails.application.routes.recognize_path(request.referer)
        controller_path = referer_params[:controller]

        if controller_path == "legislation/proposals" && referer_params[:process_id]
          { controller: "/legislation/processes", id: referer_params[:process_id], action: :proposals }
        else
          referer_params.except(:id).merge({
            controller: "/#{controller_path}",
            action: :index
          })
        end
      else
        { action: :index }
      end
    end
end
