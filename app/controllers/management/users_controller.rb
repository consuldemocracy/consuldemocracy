class Management::UsersController < Management::BaseController

  def new
    @user = User.new(user_params)
  end

  def create
    @user = User.new(user_params)
    @user.skip_password_validation = true
    @user.terms_of_service = '1'
    @user.residence_verified_at = Time.now
    @user.verified_at = Time.now

    if @user.save then
      render :show
    else
      render :new
    end
  end

  private

    def user_params
      params.require(:user).permit(:document_type, :document_number, :username, :email)
    end

end
