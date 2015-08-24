class Admin::ModeratorsController < Admin::BaseController
  def index
    @moderators = User.joins(:moderator).page(params[:page])
  end
  def search
    @email = params[:email]
    @user = User.find_by(email: @email)

    respond_to do |format|
      format.js
    end
  end
  def toggle
    @user = User.find(params[:id])
    @user.toggle_moderator
    redirect_to admin_moderators_path
  end
end
