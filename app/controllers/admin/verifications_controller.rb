class Admin::VerificationsController < Admin::BaseController

  def index
    @users = User.unverified.page(params[:page])
  end

  def search
    @users = User.unverified.search(params[:name_or_email]).page(params[:page]).for_render
    render :index
  end

end