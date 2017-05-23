class Management::EmailVerificationsController < Management::BaseController

  def new
    @email_verification = Verification::Management::Email.new(email_verification_params)
  end

  def create
    @email_verification = Verification::Management::Email.new(email_verification_params)

    if @email_verification.save
      render :sent
    else
      render :new
    end
  end

  private

    def email_verification_params
      params.require(:email_verification).permit(:document_type, :document_number, :email)
    end

end