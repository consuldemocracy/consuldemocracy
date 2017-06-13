class Admin::UsersController < Admin::BaseController
  load_and_authorize_resource

  def index
    if params[:search]
      s = params[:search]
      @users = User.where("username ILIKE ? OR email ILIKE ? OR document_number ILIKE ?", "%#{s}%","%#{s}%","%#{s}%").page(params[:page])
    else
      @users = @users.page(params[:page])
    end
    respond_to do |format|
      format.html
      format.js
    end
  end
end
