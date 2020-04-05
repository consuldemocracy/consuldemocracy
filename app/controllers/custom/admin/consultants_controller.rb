class Admin::ConsultantsController < Admin::BaseController
  load_and_authorize_resource

  def index
    @consultants = @consultants.page(params[:page])
  end

  def search
    @user = User.find_by(email: params[:email])

    respond_to do |format|
      if @user
        @consultant = Consultant.find_or_initialize_by(user: @user)
        format.js
      else
        format.js { render "user_not_found" }
      end
    end
  end

  def create
    @consultant.user_id = params[:user_id]
    @consultant.save!

    redirect_to admin_consultants_path
  end

  def destroy
    @consultant.destroy!
    redirect_to admin_consultants_path
  end
end
