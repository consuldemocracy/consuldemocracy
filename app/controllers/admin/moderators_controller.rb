class Admin::ModeratorsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @moderators = @moderators.page(params[:page])
  end

  def search
    @users = User.search(params[:search]).includes(:moderator).page(params[:page])
  end

  def create
    Moderator.find_or_create_by_user_id(params[:user_id])

    redirect_to admin_moderators_path
  end

  def destroy
    @moderator.destroy!
    redirect_to admin_moderators_path
  end
end
