class Admin::VerificationsController < Admin::BaseController

  def index
    @users = User.all.page(params[:page])
  end

end