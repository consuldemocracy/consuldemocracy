class Admin::ModeratorsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @moderators = @moderators.page(params[:page])
  end

  def search
    @user = User.find_by(email: params[:email])

    respond_to do |format|
      if @user
        @moderator = Moderator.find_or_initialize_by(user: @user)
        format.js
      else
        format.js { render "user_not_found" }
      end
    end
  end

  def destroy
    @moderator.destroy
    redirect_to admin_moderators_path
  end

  def create
    @moderator.user_id = params[:user_id]
    @moderator.save

    redirect_to admin_moderators_path
  end
end
