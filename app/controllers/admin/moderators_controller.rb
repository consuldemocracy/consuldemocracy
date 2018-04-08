class Admin::ModeratorsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @moderators = @moderators.page(params[:page])
  end

  def search
    @users = User.search(params[:name_or_email])
                 .includes(:moderator)
                 .page(params[:page])
                 .for_render
  end

  def create
    @moderator.user_id = params[:user_id]
    @moderator.save

    redirect_to admin_moderators_path
  end

  def destroy
    @moderator.destroy
    redirect_to admin_moderators_path
  end
end
