class Admin::Poll::OfficersController < Admin::Poll::BaseController
  load_and_authorize_resource :officer, class: "Poll::Officer", except: [:edit, :show]

  def index
    @officers = @officers.page(params[:page])
  end

  def search
    @user = User.find_by(email: params[:search])

    respond_to do |format|
      if @user
        @officer = Poll::Officer.find_or_initialize_by(user: @user)
        format.js
      else
        format.js { render "user_not_found" }
      end
    end
  end

  def create
    @officer.user_id = params[:user_id]
    @officer.save!

    redirect_to admin_officers_path
  end

  def destroy
    @officer.destroy!
    redirect_to admin_officers_path
  end
end
