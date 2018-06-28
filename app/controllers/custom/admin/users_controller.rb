require_dependency Rails.root.join('app', 'controllers', 'admin', 'users_controller').to_s

class Admin::UsersController < Admin::BaseController

  def cdj_show
    @user = User.find(params[:id])
  end

end
