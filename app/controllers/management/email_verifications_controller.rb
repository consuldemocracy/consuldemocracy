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
  
  def date_of_birth    
  end
  
  def save_date_of_birth
    user = User.where(email_verification_token: params[:email_verification_token]).first
    user.date_of_birth = date_of_birth
  end

  private

    def email_verification_params
      params.require(:email_verification).permit(:document_type, :document_number, :email)
    end    
    
    def date_of_birth
      date_params = params.require(:date).permit(:day, :month, :year)
      DateTime.new(date_params[:year], date_params[:month], date_params[:day])
    end

end