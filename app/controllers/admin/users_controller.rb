class Admin::UsersController < Admin::BaseController
  load_and_authorize_resource

  def index
    if params[:search]
      @users = User.by_username_email_or_document_number(params[:search]).page(params[:page])
    else
      @users = @users.page(params[:page])
    end

    respond_to do |format|
      format.html
      format.js
    end
  end
end
