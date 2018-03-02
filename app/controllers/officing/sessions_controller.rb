class Officing::SessionsController < Officing::BaseController
  skip_before_action :verify_officer
  skip_before_action :authenticate_user!

  layout "nvotes"

  def new
    @officer = User.new
  end

  def create
    @officer = User.where(email: session[:officer_email]).first
    if @officer && @officer.valid_password?(officer_params[:password])
      sign_in(@officer)
      redirect_to new_officing_residence_path
    else
      flash.now[:alert] = I18n.t("officing.sessions.create.flash.wrong_password")
      render :new
    end
  end

  private

  def officer_params
    params.require(:officer).permit(:email, :password)
  end

end