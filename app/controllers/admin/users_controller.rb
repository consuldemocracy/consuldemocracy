class Admin::UsersController < Admin::BaseController
  load_and_authorize_resource

  has_filters %w[active erased], only: :index

  def index
    @users = @users.send(@current_filter)
    @users = @users.by_username_email_or_document_number(params[:search]) if params[:search]
    @users = @users.page(params[:page])
    respond_to do |format|
      format.html
      format.js
    end
  end
end
