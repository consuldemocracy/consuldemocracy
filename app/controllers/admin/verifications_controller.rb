class Admin::VerificationsController < Admin::BaseController

  def index
    @users = User.unverified.page(params[:page])
  end

end